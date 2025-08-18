#!/usr/bin/perl
use utf8;
use Text::CSV;
use MaxMind::DB::Writer::Tree;
use open qw(:std :encoding(UTF-8));

# 支持的语言列表
my @languages = qw(de en es fr ja pt-BR ru zh-CN);

# 声明数据结构中的数据类型
my %types = (
    continent => 'map',
    country => 'map',
    registered_country => 'map',
    city => 'map',
    location => 'map',
    names => 'map',
    subdivisions => ['array', 'map'],
    # 新增字段类型
    code => 'utf8_string',
    geoname_id => 'uint32',
    iso_code => 'utf8_string',
    latitude => 'double',
    longitude => 'double',
    accuracy_radius => 'uint16',
    time_zone => 'utf8_string',
);

# 为所有语言添加类型
foreach my $lang (@languages) {
    $types{$lang} = 'utf8_string';
}

# 创建树 - 支持IPv6
my $tree = MaxMind::DB::Writer::Tree->new(
    ip_version            => 6,
    record_size           => 28,
    database_type        => 'GeoLite2-City-DN42',
    languages            => \@languages,
    description          => {
        en => 'GeoLite2 City database DN42',
        'zh-CN' => "GeoCity数据库DN42版",
        map { $_ => "GeoLite2 City database DN42" } grep { $_ ne 'en' && $_ ne 'zh-CN' } @languages
    },
    map_key_type_callback => sub { $types{ $_[0] } },
    merge_strategy       => 'none',        # 改为 none，禁用自动合并
    alias_ipv6_to_ipv4   => 0,
    remove_reserved_networks => 0
);

# continent 多语言映射
my %continent_names;
my %continent_codes;

# registered_country 信息
my %registered_countrydb;

# 初始化CSV解析器
my $csv = Text::CSV->new({
    binary                => 1,
    decode_utf8           => 1,
    auto_diag             => 1,
    diag_verbose          => 1,
    allow_loose_quotes    => 1,
    allow_loose_escapes   => 1,
    allow_unquoted_escape => 1,
});

# 位置数据库
my %locationdb;
my %country_iso_codes;  # 新增：存储国家 ISO 代码

# 加载处理所有语言的位置文件
foreach my $lang (@languages) {
    my $location_file = "./GeoLite2-City-csv/GeoLite2-City-Locations-$lang.csv";
    unless (-e $location_file) {
        warn "Location file not found: $location_file. Skipping.\n";
        next;
    }
    open(my $fh, '<', $location_file) or do {
        warn "Could not open '$location_file': $!. Skipping.\n";
        next;
    };
    my $first = 1;
    while (my $line = <$fh>) {
        next if $first && $first--;  # 跳过标题行
        if ($csv->parse($line)) {
            my @fields = $csv->fields();
            my $geoname_id = $fields[0];
            my $continent_code = $fields[2];
            my $continent_name = $fields[3];
            my $country_iso_code = $fields[4];
            my $country_name = $fields[5];
            my $subdiv1_name = $fields[7];
            my $subdiv2_name = $fields[9];
            my $city_name = $fields[10];
            my $time_zone = $fields[12];

            # continent 多语言
            $continent_names{$continent_code}{$lang} = $continent_name if $continent_code && $continent_name;
            $continent_codes{$geoname_id} = $continent_code if $geoname_id && $continent_code;

            # 国家信息
            $locationdb{$geoname_id}{country}{$lang} = $country_name if $country_name;

            # 保存国家 ISO 代码
            if ($country_iso_code && $country_iso_code ne '') {
                $country_iso_codes{$geoname_id} = $country_iso_code;
            }

            # 一级行政区
            if ($subdiv1_name && $subdiv1_name ne '') {
                $locationdb{$geoname_id}{subdivisions}[0] = {} unless exists $locationdb{$geoname_id}{subdivisions}[0];
                $locationdb{$geoname_id}{subdivisions}[0]{$lang} = $subdiv1_name;
            }
            # 二级行政区
            if ($subdiv2_name && $subdiv2_name ne '') {
                $locationdb{$geoname_id}{subdivisions}[1] = {} unless exists $locationdb{$geoname_id}{subdivisions}[1];
                $locationdb{$geoname_id}{subdivisions}[1]{$lang} = $subdiv2_name;
            }
            # 城市
            $locationdb{$geoname_id}{city}{$lang} = $city_name if $city_name;

            # 保存time_zone信息
            if ($time_zone && $time_zone ne '') {
                $locationdb{$geoname_id}{time_zone} = $time_zone;
            }

            # registered_country 信息
            $registered_countrydb{$geoname_id}{country}{$lang} = $country_name if $country_name;
            $registered_countrydb{$geoname_id}{continent_code} = $continent_code if $continent_code;
        } else {
            warn "Line could not be parsed in $location_file: $line\n";
        }
    }
    close($fh);
    print "Processed: $location_file\n";
}

# continent geoname_id 到 names 的映射
my %continent_geoname_id = (
    'AF' => 6255146, # Africa
    'AS' => 6255147, # Asia
    'EU' => 6255148, # Europe
    'NA' => 6255149, # North America
    'OC' => 6255151, # Oceania
    'SA' => 6255150, # South America
    'AN' => 6255152, # Antarctica
);

# 插入CIDR和信息的子程序（重写）
sub insert_cidr_and_info {
    my ($cidr, $info) = @_;
    my %geoinfo;
    my $has_valid_data = 0;

    # continent 数据完整性检查
    if ($info->{continent_code} && 
        exists $continent_names{$info->{continent_code}} && 
        %{$continent_names{$info->{continent_code}}}) {
        
        my $ccode = $info->{continent_code};
        my $cid = $continent_geoname_id{$ccode} || 0;
        $geoinfo{continent} = {
            code       => $ccode,
            geoname_id => $cid,
            names      => $continent_names{$ccode},
        };
        $has_valid_data = 1;
    }

    # country 数据完整性检查
    if ($info->{country} && %{$info->{country}} && 
        $info->{country_geoname_id} && 
        $info->{country_iso_code}) {
        
        $geoinfo{country} = {
            geoname_id => int($info->{country_geoname_id}),
            iso_code   => $info->{country_iso_code},
            names      => $info->{country},
        };
        $has_valid_data = 1;
    }

    # registered_country 数据完整性检查
    if ($info->{registered_country} && %{$info->{registered_country}} &&
        $info->{registered_country_geoname_id} &&
        $info->{registered_country_iso_code}) {
        
        $geoinfo{registered_country} = {
            geoname_id => int($info->{registered_country_geoname_id}),
            iso_code   => $info->{registered_country_iso_code},
            names      => $info->{registered_country},
        };
        $has_valid_data = 1;
    }

    # city 数据完整性检查
    if ($info->{city} && %{$info->{city}}) {
        $geoinfo{city} = {
            names => $info->{city}
        };
        $has_valid_data = 1;
    }

    # subdivisions 数据完整性检查
    if ($info->{subdivisions} && @{$info->{subdivisions}}) {
        my @valid_subdivs;
        foreach my $subdiv (@{$info->{subdivisions}}) {
            if ($subdiv && %$subdiv) {
                push @valid_subdivs, { names => $subdiv };
            }
        }
        if (@valid_subdivs) {
            $geoinfo{subdivisions} = \@valid_subdivs;
            $has_valid_data = 1;
        }
    }

    # location 数据完整性检查
    if (defined $info->{location}{latitude} && 
        defined $info->{location}{longitude} && 
        defined $info->{location}{accuracy_radius}) {
        
        $geoinfo{location} = {
            latitude        => $info->{location}{latitude} + 0.0,
            longitude       => $info->{location}{longitude} + 0.0,
            accuracy_radius => int($info->{location}{accuracy_radius}),
        };
        
        # 只有在时区存在且有效时才添加
        if (defined $info->{location}{time_zone} && 
            $info->{location}{time_zone} ne '') {
            $geoinfo{location}{time_zone} = $info->{location}{time_zone};
        }
        $has_valid_data = 1;
    }

    # 只在有完整有效数据时才插入
    if ($has_valid_data) {
        $tree->insert_network($cidr, \%geoinfo);
    }
}


# 处理IPv4和IPv6地址块
foreach my $version (qw(IPv4 IPv6)) {
    my $block_file = "./GeoLite2-City-csv/GeoLite2-City-Blocks-$version.csv";
    unless (-e $block_file) {
        warn "Block file not found: $block_file. Skipping.\n";
        next;
    }
    open(my $fh, '<', $block_file) or do {
        warn "Could not open '$block_file': $!. Skipping.\n";
        next;
    };
    my $first = 1;
    while (my $line = <$fh>) {
        next if $first && $first--;  # 跳过标题行
        if ($csv->parse($line)) {
            my @fields = $csv->fields();
            my $network = $fields[0];
            my $geoname_id = $fields[1];
            my $registered_country_geoname_id = $fields[2];
            # ...existing fields...
            my $latitude = $fields[7];
            my $longitude = $fields[8];
            my $accuracy_radius = $fields[9];
            my $time_zone = $fields[11];

            # 组装 info
            my $info = {};
            
            # 只处理有效的 geoname_id
            if ($geoname_id && exists $locationdb{$geoname_id}) {
                # continent_code
                if ($continent_codes{$geoname_id}) {
                    $info->{continent_code} = $continent_codes{$geoname_id};
                } elsif ($registered_country_geoname_id && $continent_codes{$registered_country_geoname_id}) {
                    $info->{continent_code} = $continent_codes{$registered_country_geoname_id};
                }

                # country
                if ($locationdb{$geoname_id}{country} && %{$locationdb{$geoname_id}{country}}) {
                    $info->{country} = $locationdb{$geoname_id}{country};
                    $info->{country_geoname_id} = int($geoname_id);
                    $info->{country_iso_code} = $country_iso_codes{$geoname_id} if exists $country_iso_codes{$geoname_id};
                }

                # city & subdivisions
                $info->{city} = $locationdb{$geoname_id}{city} 
                    if exists $locationdb{$geoname_id}{city} && %{$locationdb{$geoname_id}{city}};
                $info->{subdivisions} = $locationdb{$geoname_id}{subdivisions}
                    if exists $locationdb{$geoname_id}{subdivisions} && @{$locationdb{$geoname_id}{subdivisions}};
            }

            # registered_country
            if ($registered_country_geoname_id && exists $registered_countrydb{$registered_country_geoname_id}) {
                if ($registered_countrydb{$registered_country_geoname_id}{country} &&
                    %{$registered_countrydb{$registered_country_geoname_id}{country}}) {
                    $info->{registered_country} = $registered_countrydb{$registered_country_geoname_id}{country};
                    $info->{registered_country_geoname_id} = int($registered_country_geoname_id);
                    $info->{registered_country_iso_code} = $country_iso_codes{$registered_country_geoname_id}
                        if exists $country_iso_codes{$registered_country_geoname_id};
                }
            }

            # location信息处理
            if (defined $latitude && $latitude ne '' && defined $longitude && $longitude ne '') {
                $info->{location} = {
                    latitude         => $latitude + 0.0,
                    longitude       => $longitude + 0.0,
                    accuracy_radius  => int($accuracy_radius || 0),
                };
                
                # 优先使用块文件中的time_zone，如果没有则使用位置文件中的time_zone
                my $tz = $time_zone;
                if (!defined $tz || $tz eq '') {
                    $tz = $locationdb{$geoname_id}{time_zone} if $geoname_id && exists $locationdb{$geoname_id}{time_zone};
                }
                $info->{location}{time_zone} = $tz if defined $tz && $tz ne '';
            }

            # 只在有效数据时插入
            if (%$info) {
                insert_cidr_and_info($network, $info);
            }
           } else {
            warn "Line could not be parsed in $block_file: $line\n";
        }
    }
    close($fh);
    print "Processed: $block_file\n";
}

# 写入数据库
open my $out_fh, '>:raw', 'GeoLite2-City-DN42.mmdb';
$tree->write_tree($out_fh);
close $out_fh;

print "Database created successfully: GeoLite2-DN42.mmdb\n";
