# ***DN42-Geoip项目***

> 数据非常少，需要大家一起贡献

---

## **说明**

[English](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/README_en.md)

本文中使用的 ISO 编码遵循 [ISO3166](https://www.iso.org/iso-3166-country-codes.html) 标准，包含二位字母码和三位字母码。

国家/地区、一级行政区名称及 ISO 编码，城市名称可参考：[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv)。

本仓库每天 UTC 时间凌晨 2 点构建新的 `.mmdb` 文件并发布到 [Releases](https://github.com/Xe-iu/dn42-geoip/releases)。

---

## **数据结构**

| 字段                | 说明           | 必要性 | 备注                                                                |
| ----------------- | ------------ | --- | ----------------------------------------------------------------- |
| `country`         | 国家或地区        | 必填  |                                                                   |
| `country_code`    | 国家或地区 ISO 代码 | 必填  |                                                                   |
| `region`          | 一级行政区        | 选填  | 填写 city 时必须有 region，特殊情况可省略                                       |
| `region_code`     | 一级行政区 ISO 代码 | 选填  | 填写 region 时必填                                                     |
| `city`            | 城市（一般为二级行政区） | 选填  | 填写 city 时必须有 region，除非无 region（如澳门）                               |
| `latitude`        | 纬度           | 必填  | 精确到最小行政区即可，                                                        |
| `longitude`       | 经度           | 必填  | 精确到最小行政区即可                                                        |
| `accuracy_radius` | 经纬度精确半径      | 必填  | 适当填写即可，不必太精确                                                      |
| `source`          | 网段注册源        | 必填  | 可填写 `DN42`、`NeoNetwork`、`ICVPN`、`ChaosVPN`、`CRXN` 或其它与 DN42 互联的网络 |

---

## **示例**

```toml
[172.20.159.0/28]			      #整个网段（主网段）
country =      "China"		  #在DN42注册时所填写的国家或地区
country_code = "CN"			    #国家或地区的iso码
                            #这里的经纬度不用填写，其它必填
source =       "DN42"		    #在最大网段是必填的，其它选填。

[172.20.159.1/32]				      #节点IP
country =      "Japan"		    #节点所在的国家或地区
country_code = "JP"			      #国家或地区的iso码
region =       "Tokyo"		    #所在的一级行政区（没有可以不用写）
region_code =  "13"			      #所在的一级行政区的iso码（没有可以不用写）
city =         "Tokyo"		    #所在城市（一般为二级行政区）
latitude =      35.6937632	  #纬度（精确到你填写的最小的行政区即可）
longitude =     139.7036319	  #纬度（精确到你填写的最小的行政区即可）
accuracy_radius=50			      #半径（随便填啦，不要太离谱即可）
```

---

## **提交 Geoip 数据**

本项目支持通过发布的 Geofeed 自动更新数据，也可以手动提交数据。

请注意：**如果您已发布 Geofeed，请勿手动修改数据，会被 Geofeed 数据覆盖。直接修改你发布的 Geofeed 即可。**

### 发布 Geofeed

1. 依照 [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html) 编写 Geofeed CSV 文件
2. 依照 [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html) 将 Geofeed 网址发布到 DN42 Registry
3. 本项目UTC时间每周日0点会自动抓取 Geofeed 文件，更新数据

### 手动提交

1. Fork 本仓库
2. 在 `data/ipv4` 或 `data/ipv6` 文件夹内新建文件，填写内容
3. 文件名格式：使用你的 DN42 网段，将 `/` 替换为 `_`，然后加 `.toml` 后缀
   例如：`172.20.159.0_28.toml`
4. 提交时请使用网段 inetnum/inet6num 中任意一个 `mnt-by` 的 **PGP** 或 **SSH** 密钥签名
5. 发起 PR 等待审核合并

---

## **.mmdb 文件结构示例**

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
          50 <uint16>
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

---

## **手动生成 `.mmdb` 文件**

1. 安装依赖：

```bash
sudo apt install libmaxmind-db-writer-perl
curl -L https://cpanm.pm/Cpanm/install | perl - -install
cpanm Net::Works::Network Text::CSV
```

2. 克隆仓库：

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip
```

3. TOML 转 CSV：

```bash
./toml2csv
```

4. 生成 `.mmdb` 文件：

```bash
perl build_mmdb.pl
```

5. 成功后会在根目录得到 `GeoLite2-City-DN42.mmdb` 文件

---

## **数据来源**

* 国家、城市名称数据：[maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)
