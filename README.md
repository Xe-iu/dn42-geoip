# ***DN42-Geoip项目***
 数据非常少，需要大家一起贡献
 
 -----
**本文的ISO编码指的是 ISO3166 标准中二位字母代码、三位字母代码**

**国家或地区、一级行政区的名称和ISO编码，城市名称表格：[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv)**

**本仓库每天会构建新的mmdb文件到releases**

 **数据结构：**
 
 
| 字段 | 说明 | 必要性 | 备注 |
| - | - | - | - |
| country | 国家或地区 | 必填 |
| country_code | 国家或地区的ISO编码 | 必填 |
| region | 一级行政区 | 选填 |
| region_code | 一级行政区的ISO编码 | 选填 | 如果region已填写则该字段为必填 |
| city | 城市（一般为二级行政区） | 选填 | 如果该已填写则region字段为必填 |
| latitude | 纬度 | 必填 | 精确到所填写的最小的行政区即可 |
| longitude | 经度 | 必填 | 精确到所填写的最小的行政区即可 |
| accuracy_radius | 经纬度精确半径 | 必填 | 随便填啦，不要太离谱即可 |

**示例：**

```
 [172.20.159.0/28]			   #整个网段
country =      "China"		   #在DN42注册时所填写的国家或地区
country_code = "CN"			  #国家或地区的iso码
latitude =      39.906217		#纬度（精确到你填写的最小的行政区即可）
longitude =     116.3912757      #纬度（精确到你填写的最小的行政区即可）
accuracy_radius=200              #半径（随便填啦，不要太离谱即可）
source =       "DN42"		    #在最大网段是必填的，其它选填。

[172.20.159.1/32]				#节点IP
country =      "Japan"		   #节点所在的国家或地区
country_code = "JP"			  #国家或地区的iso码
region =       "Tokyo"		   #所在的一级行政区（没有可以不用写）
region_code =  "13"			  #所在的一级行政区的iso码（没有可以不用写）
city =         "Tokyo"		   #所在城市（一般为二级行政区）
latitude =      35.6937632	   #纬度（精确到你填写的最小的行政区即可）
longitude =     139.7036319	  #纬度（精确到你填写的最小的行政区即可）
accuracy_radius=200			  #半径（随便填啦，不要太离谱即可）
```
---

# **提交您的Geoip数据**
Fork该仓库

按上面的数据结构的解释，在data目录的ipv4或ipv6文件夹内新建文件填写内容 

文件名需用你在DN42取得的网段，使用其CIRD的形式，把 “/”改为“_”，在其后加上 .toml 即可

填写完成后使用您在DN42注册时提交的PGP或SSH密钥签名提交

然后提PR等待审核合并即可

---

**```GeoLite2-City-DN42.mmdb```的数据结构**

```
root@xeiuserver:/opt/dn42/geo-ip-master# mmdblookup --file GeoLite2-City-DN42.mmdb -i fd43:83b9:82e2:face::

  {
    "city": 
      {
        "names": 
          {
            "de": 
              "Tokio" <utf8_string>
            "en": 
              "Tokyo" <utf8_string>
            "es": 
              "Tokio" <utf8_string>
            "fr": 
              "Tokyo" <utf8_string>
            "ja": 
              "東京" <utf8_string>
            "pt-BR": 
              "Tóquio" <utf8_string>
            "ru": 
              "Токио" <utf8_string>
            "zh-CN": 
              "东京" <utf8_string>
          }
      }
    "continent": 
      {
        "code": 
          "AS" <utf8_string>
        "geoname_id": 
          6255147 <uint32>
        "names": 
          {
            "de": 
              "Asien" <utf8_string>
            "en": 
              "Asia" <utf8_string>
            "es": 
              "Asia" <utf8_string>
            "fr": 
              "Asie" <utf8_string>
            "ja": 
              "アジア" <utf8_string>
            "pt-BR": 
              "Ásia" <utf8_string>
            "ru": 
              "Азия" <utf8_string>
            "zh-CN": 
              "亚洲" <utf8_string>
          }
      }
    "country": 
      {
        "geoname_id": 
          1850147 <uint32>
        "iso_code": 
          "JP" <utf8_string>
        "names": 
          {
            "de": 
              "Japan" <utf8_string>
            "en": 
              "Japan" <utf8_string>
            "es": 
              "Japón" <utf8_string>
            "fr": 
              "Japon" <utf8_string>
            "ja": 
              "日本" <utf8_string>
            "pt-BR": 
              "Japão" <utf8_string>
            "ru": 
              "Япония" <utf8_string>
            "zh-CN": 
              "日本" <utf8_string>
          }
      }
    "location": 
      {
        "accuracy_radius": 
          200 <uint16>
        "latitude": 
          35.693763 <double>
        "longitude": 
          139.703632 <double>
        "time_zone": 
          "Asia/Tokyo" <utf8_string>
      }
    "registered_country": 
      {
        "geoname_id": 
          1861060 <uint32>
        "iso_code": 
          "JP" <utf8_string>
        "names": 
          {
            "de": 
              "Japan" <utf8_string>
            "en": 
              "Japan" <utf8_string>
            "es": 
              "Japón" <utf8_string>
            "fr": 
              "Japon" <utf8_string>
            "ja": 
              "日本" <utf8_string>
            "pt-BR": 
              "Japão" <utf8_string>
            "ru": 
              "Япония" <utf8_string>
            "zh-CN": 
              "日本" <utf8_string>
          }
      }
    "subdivisions": 
      [
        {
          "names": 
            {
              "de": 
                "Tokio" <utf8_string>
              "en": 
                "Tokyo" <utf8_string>
              "es": 
                "Tokio" <utf8_string>
              "fr": 
                "Préfecture de Tokyo" <utf8_string>
              "ja": 
                "東京都" <utf8_string>
              "pt-BR": 
                "Tóquio" <utf8_string>
              "ru": 
                "Токио" <utf8_string>
              "zh-CN": 
                "东京都" <utf8_string>
            }
        }
      ]
  }


```
# **自助生成.mmdb文件**
本仓库默认提供八国语言的mmdb，可以git clone 仓库后修改build_mmdb.pl文件内容，简化或添加你想要的数据结构。

Debian系统有 libmaxmind-db-writer-perl 软件包，
debian系的linux发行版可使用 ``` apt install libmaxmind-db-writer-perl ``` 安装。

也可以手动安装：
前往 [libmaxmind-db-writer-perl](https://github.com/maxmind/MaxMind-DB-Writer-perl) 的github仓库手动安装。

然后安装cpanm ``` curl -L https://cpanm.pm/Cpanm/install | perl - -install ```

执行 ``` cpanm Net::Works::Network Text::CSV ``` 安装生成.mmdb文件需要的 Perl 模块

git clone 仓库，进入到仓库的根目录

执行 ```./toml2csv ``` 把toml转换成csv
执行 ``` perl build_mmdb.pl ``` 生成

生成完成即可在根目录找到名为 ``` GeoLite2-City-DN42.mmdb ``` 的数据库文件。



# **数据来源**
国家或地区、城市名称数据：[maxmind-geoip -- Github](https://github.com/8bitsaver/maxmind-geoip)
