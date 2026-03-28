#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use Text::CSV;
use MaxMind::DB::Writer::Tree;
use open qw(:std :encoding(UTF-8));

# Output language keys expected in MMDB
my @languages = qw(de en es fr ja pt-BR ru zh-hans zh-hant);
my @address_keys = qw(default de en es fr ja pt-BR ru zh-hans zh-hant);

my %types = (
    continent          => 'map',
    country            => 'map',
    registered_country => 'map',
    city               => 'map',
    location           => 'map',
    traits             => 'map',
    names              => 'map',
    subdivisions       => ['array', 'map'],
    address            => ['array', 'map'],

    code            => 'utf8_string',
    geoname_id      => 'uint32',
    iso_code        => 'utf8_string',
    latitude        => 'double',
    longitude       => 'double',
    accuracy_radius => 'uint16',
    time_zone       => 'utf8_string',
    default         => 'utf8_string',
    is_anycast      => 'boolean',
);

foreach my $lang (@languages) {
    $types{$lang} = 'utf8_string';
}

my $tree = MaxMind::DB::Writer::Tree->new(
    ip_version              => 6,
    record_size             => 28,
    database_type           => 'GeoLite2-City-DN42',
    languages               => \@languages,
    description             => {
        en      => 'GeoLite2 City database DN42',
        'zh-hans' => 'GeoLite2 City database DN42',
        map { $_ => 'GeoLite2 City database DN42' } grep { $_ ne 'en' && $_ ne 'zh-hans' } @languages,
    },
    map_key_type_callback   => sub { $types{ $_[0] } },
    merge_strategy          => 'none',
    alias_ipv6_to_ipv4      => 0,
    remove_reserved_networks => 0,
);

my %continent_names;
my %continent_codes;
my %registered_countrydb;
my %locationdb;
my %country_iso_codes;

my %continent_geoname_id = (
    AF => 6255146,
    AS => 6255147,
    EU => 6255148,
    NA => 6255149,
    OC => 6255151,
    SA => 6255150,
    AN => 6255152,
);

my @location_file_lang_map = (
    [ 'de',      'de'      ],
    [ 'en',      'en'      ],
    [ 'es',      'es'      ],
    [ 'fr',      'fr'      ],
    [ 'ja',      'ja'      ],
    [ 'pt-BR',   'pt-BR'   ],
    [ 'ru',      'ru'      ],
    [ 'zh-hans', 'zh-Hans' ],
    [ 'zh-hant', 'zh-Hant' ],
);

my $csv = Text::CSV->new({
    binary                => 1,
    decode_utf8           => 1,
    auto_diag             => 1,
    allow_loose_quotes    => 1,
    allow_loose_escapes   => 1,
    allow_unquoted_escape => 1,
});

sub fill_language_names {
    my ($names) = @_;
    my %out;
    foreach my $lang (@languages) {
        $out{$lang} = exists $names->{$lang} ? $names->{$lang} : '';
    }
    return \%out;
}

sub fill_address_names {
    my ($names) = @_;
    my %out;
    foreach my $k (@address_keys) {
        $out{$k} = exists $names->{$k} ? $names->{$k} : '';
    }
    return \%out;
}

sub load_locations {
    foreach my $pair (@location_file_lang_map) {
        my ($out_lang, $file_lang) = @$pair;
        my $location_file = "./GeoLite2-City-csv/GeoLite2-City-Locations-$file_lang.csv";
        unless (-e $location_file) {
            warn "Location file not found: $location_file. Skipping.\n";
            next;
        }

        open(my $fh, '<', $location_file) or do {
            warn "Could not open '$location_file': $!. Skipping.\n";
            next;
        };

        my $header = $csv->getline($fh);
        next unless $header;

        while (my $row = $csv->getline($fh)) {
            my (
                $geoname_id,
                undef,
                $continent_code,
                $continent_name,
                $country_iso_code,
                $country_name,
                undef,
                $subdiv1_name,
                undef,
                $subdiv2_name,
                $city_name,
                undef,
                $time_zone,
            ) = @$row;

            next unless defined $geoname_id && $geoname_id ne '';

            if (defined $continent_code && $continent_code ne '' && defined $continent_name && $continent_name ne '') {
                $continent_names{$continent_code}{$out_lang} = $continent_name;
                $continent_codes{$geoname_id} = $continent_code;
            }

            if (defined $country_name && $country_name ne '') {
                $locationdb{$geoname_id}{country}{$out_lang} = $country_name;
                $registered_countrydb{$geoname_id}{country}{$out_lang} = $country_name;
            }

            if (defined $country_iso_code && $country_iso_code ne '') {
                $country_iso_codes{$geoname_id} = $country_iso_code;
            }

            if (defined $subdiv1_name && $subdiv1_name ne '') {
                $locationdb{$geoname_id}{subdivisions}[0] ||= {};
                $locationdb{$geoname_id}{subdivisions}[0]{$out_lang} = $subdiv1_name;
            }

            if (defined $subdiv2_name && $subdiv2_name ne '') {
                $locationdb{$geoname_id}{subdivisions}[1] ||= {};
                $locationdb{$geoname_id}{subdivisions}[1]{$out_lang} = $subdiv2_name;
            }

            if (defined $city_name && $city_name ne '') {
                $locationdb{$geoname_id}{city}{$out_lang} = $city_name;
            }

            if (defined $time_zone && $time_zone ne '') {
                $locationdb{$geoname_id}{time_zone} = $time_zone;
            }

            if (defined $continent_code && $continent_code ne '') {
                $registered_countrydb{$geoname_id}{continent_code} = $continent_code;
            }
        }

        close($fh);
        print "Processed: $location_file\n";
    }
}

sub load_address_blocks {
    my %addressdb;

    foreach my $version (qw(IPv4 IPv6)) {
        my $file = "./GeoLite2-City-csv/GeoLite2-Address-Blocks-$version.csv";
        next unless -e $file;

        open(my $fh, '<', $file) or do {
            warn "Could not open '$file': $!. Skipping.\n";
            next;
        };

        my $header = $csv->getline($fh);
        next unless $header;

        my %idx;
        for my $i (0 .. $#$header) {
            $idx{$header->[$i]} = $i;
        }

        while (my $row = $csv->getline($fh)) {
            my $network = $row->[ $idx{network} ];
            next unless defined $network && $network ne '';

            my %names;
            foreach my $k (@address_keys) {
                my $i = $idx{$k};
                next unless defined $i;
                my $v = $row->[$i];
                $names{$k} = defined $v ? $v : '';
            }

            $addressdb{$network} = \%names;
        }

        close($fh);
        print "Processed: $file\n";
    }

    return %addressdb;
}

sub insert_cidr_and_info {
    my ($cidr, $info) = @_;
    my %geoinfo;
    my $has_valid_data = 0;

    if ($info->{continent_code} && exists $continent_names{$info->{continent_code}}) {
        my $ccode = $info->{continent_code};
        my $cid = $continent_geoname_id{$ccode} || 0;
        $geoinfo{continent} = {
            code       => $ccode,
            geoname_id => $cid,
            names      => fill_language_names($continent_names{$ccode}),
        };
        $has_valid_data = 1;
    }

    if ($info->{country} && %{$info->{country}} && $info->{country_geoname_id} && $info->{country_iso_code}) {
        $geoinfo{country} = {
            geoname_id => int($info->{country_geoname_id}),
            iso_code   => $info->{country_iso_code},
            names      => fill_language_names($info->{country}),
        };
        $has_valid_data = 1;
    }

    if ($info->{registered_country} && %{$info->{registered_country}} &&
        $info->{registered_country_geoname_id} && $info->{registered_country_iso_code}) {
        $geoinfo{registered_country} = {
            geoname_id => int($info->{registered_country_geoname_id}),
            iso_code   => $info->{registered_country_iso_code},
            names      => fill_language_names($info->{registered_country}),
        };
        $has_valid_data = 1;
    }

    if ($info->{city} && %{$info->{city}}) {
        $geoinfo{city} = { names => fill_language_names($info->{city}) };
        $has_valid_data = 1;
    }

    if ($info->{subdivisions} && @{$info->{subdivisions}}) {
        my @valid_subdivs;
        foreach my $subdiv (@{$info->{subdivisions}}) {
            next unless $subdiv && %$subdiv;
            push @valid_subdivs, { names => fill_language_names($subdiv) };
        }
        if (@valid_subdivs) {
            $geoinfo{subdivisions} = \@valid_subdivs;
            $has_valid_data = 1;
        }
    }

    if (defined $info->{location}{latitude} && defined $info->{location}{longitude} && defined $info->{location}{accuracy_radius}) {
        $geoinfo{location} = {
            latitude        => $info->{location}{latitude} + 0.0,
            longitude       => $info->{location}{longitude} + 0.0,
            accuracy_radius => int($info->{location}{accuracy_radius}),
        };
        if (defined $info->{location}{time_zone} && $info->{location}{time_zone} ne '') {
            $geoinfo{location}{time_zone} = $info->{location}{time_zone};
        }
        $has_valid_data = 1;
    }

    if (defined $info->{traits}{is_anycast}) {
        $geoinfo{traits} = {
            is_anycast => $info->{traits}{is_anycast} ? 1 : 0,
        };
        $has_valid_data = 1;
    }

    if ($info->{address_names} && %{$info->{address_names}}) {
        $geoinfo{address} = [
            {
                names => fill_address_names($info->{address_names}),
            }
        ];
        $has_valid_data = 1;
    }

    if ($has_valid_data) {
        $tree->insert_network($cidr, \%geoinfo);
    }
}

sub process_blocks {
    my (%addressdb) = @_;

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

        my $header = $csv->getline($fh);
        next unless $header;

        my %idx;
        for my $i (0 .. $#$header) {
            $idx{$header->[$i]} = $i;
        }

        while (my $row = $csv->getline($fh)) {
            my $network = $row->[ $idx{network} // 0 ];
            next unless defined $network && $network ne '';

            my $geoname_id = $row->[ $idx{geoname_id} // 1 ];
            my $registered_country_geoname_id = $row->[ $idx{registered_country_geoname_id} // 2 ];
            my $latitude = $row->[ $idx{latitude} // 7 ];
            my $longitude = $row->[ $idx{longitude} // 8 ];
            my $accuracy_radius = $row->[ $idx{accuracy_radius} // 9 ];
            my $is_anycast = exists $idx{is_anycast} ? $row->[ $idx{is_anycast} ] : '';
            my $time_zone = exists $idx{time_zone} ? $row->[ $idx{time_zone} ] : undef;

            my $info = {};

            if ($geoname_id && exists $locationdb{$geoname_id}) {
                if ($continent_codes{$geoname_id}) {
                    $info->{continent_code} = $continent_codes{$geoname_id};
                } elsif ($registered_country_geoname_id && $continent_codes{$registered_country_geoname_id}) {
                    $info->{continent_code} = $continent_codes{$registered_country_geoname_id};
                }

                if ($locationdb{$geoname_id}{country} && %{$locationdb{$geoname_id}{country}}) {
                    $info->{country} = $locationdb{$geoname_id}{country};
                    $info->{country_geoname_id} = int($geoname_id);
                    $info->{country_iso_code} = $country_iso_codes{$geoname_id} if exists $country_iso_codes{$geoname_id};
                }

                $info->{city} = $locationdb{$geoname_id}{city}
                    if exists $locationdb{$geoname_id}{city} && %{$locationdb{$geoname_id}{city}};
                $info->{subdivisions} = $locationdb{$geoname_id}{subdivisions}
                    if exists $locationdb{$geoname_id}{subdivisions} && @{$locationdb{$geoname_id}{subdivisions}};
            }

            if ($registered_country_geoname_id && exists $registered_countrydb{$registered_country_geoname_id}) {
                if ($registered_countrydb{$registered_country_geoname_id}{country} &&
                    %{$registered_countrydb{$registered_country_geoname_id}{country}}) {
                    $info->{registered_country} = $registered_countrydb{$registered_country_geoname_id}{country};
                    $info->{registered_country_geoname_id} = int($registered_country_geoname_id);
                    $info->{registered_country_iso_code} = $country_iso_codes{$registered_country_geoname_id}
                        if exists $country_iso_codes{$registered_country_geoname_id};
                }
            }

            if (defined $latitude && $latitude ne '' && defined $longitude && $longitude ne '') {
                $info->{location} = {
                    latitude        => $latitude + 0.0,
                    longitude       => $longitude + 0.0,
                    accuracy_radius => int($accuracy_radius || 0),
                };

                my $tz = $time_zone;
                if ((!defined $tz || $tz eq '') && $geoname_id && exists $locationdb{$geoname_id}{time_zone}) {
                    $tz = $locationdb{$geoname_id}{time_zone};
                }
                $info->{location}{time_zone} = $tz if defined $tz && $tz ne '';
            }

            if (defined $is_anycast && $is_anycast ne '') {
                my $v = lc($is_anycast);
                my $is_true = ($v eq '1' || $v eq 'true');
                $info->{traits}{is_anycast} = $is_true ? 1 : 0;
            }

            if (exists $addressdb{$network}) {
                $info->{address_names} = $addressdb{$network};
            }

            insert_cidr_and_info($network, $info) if %$info;
        }

        close($fh);
        print "Processed: $block_file\n";
    }
}

load_locations();
my %addressdb = load_address_blocks();
process_blocks(%addressdb);

open my $out_fh, '>:raw', 'GeoLite2-City-DN42.mmdb' or die "Cannot open output MMDB: $!";
$tree->write_tree($out_fh);
close $out_fh;

print "Database created successfully: GeoLite2-City-DN42.mmdb\n";
