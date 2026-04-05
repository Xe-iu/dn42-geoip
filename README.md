# ***DN42-Geoip项目***

> 数据非常少，需要大家一起贡献

---

## **说明**

[English](./docs/README_en-US.md) 
[繁體中文](./docs/README_zh-Hant.md) 

本文中使用的 ISO 编码遵循 [ISO3166](https://www.iso.org/iso-3166-country-codes.html) 标准，包含二位字母码和三位字母码。

国家/地区、一级行政区名称及 ISO 编码，城市名称可参考：[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv)。

本仓库每天 UTC 时间凌晨 2 点构建新的 `.mmdb` 文件并发布到 [Releases](https://github.com/Xe-iu/dn42-geoip/releases)。

---

## **geoip数据文件命名规则**

与 DN42 registry 的差不多一致，区别在于geoip数据文件的名称后缀为`.toml`

示例：
```
CIDR = 172.20.159.0/28
file_name= 172.20.159.0_28.toml
```

IPv4网段请到`data/ipv4`创建
IPv6网段请到`data/ipv6`创建

**在Windows系统上无法拉取该github仓库，因为Windows系统不允许文件名中存在字符“:”。请使用Linux系统拉取。**

------------

## **示例**

[数据结构示例](./example.geoip-data.toml)

```toml
[Version]
data_version =     "1.1"                    # 数据结构版本号
create_time  = 2025-12-31T11:45:14Z         # 创建时间 (UTC | yyyy-mm-ddThh:mm:ssZ)
update_time  = 2025-12-31T11:45:14Z         # 最近修改时间 (UTC | yyyy-mm-ddThh:mm:ssZ)

[Master]
CIDR =                  "172.20.159.0/28"   # 必选/Required
country.name =          "China"             # 可选/Optional | 如未填写则fallback_to_master字段强制为false
country.code =          "CN"                # 可选/Optional
source =                "DN42"              # 必选/Required | Can be DN42, NeoNetwork, ICVPN, ChaosVPN, CRXN, or other networks interconnected with DN42

[[GeoData]]
CIDR =                  "172.20.159.1/32"   # 必选/Required
anycast =               false               # 可选/Optional | 默认false / example flase
country.name =          "Japan"             # 必选/Required
country.code =          "JP"                # 必选/Required
region.name =           "Tokyo"             # 可选/Optional
region.code =           "13"                # 可选/Optional
city =                  "Tokyo"             # 可选/Optional
latitude =              35.6937632          # 必选/Required
longitude =             139.7036319         # 必选/Required
accuracy_radius=        50                  # 必选/Required

# 试验性 / Experimental
address.default =      ""                  # 可选/Optional
address.de =           ""                  # 可选/Optional
address.en =           ""                  # 可选/Optional
address.es =           ""                  # 可选/Optional
address.fr =           ""                  # 可选/Optional
address.ja =           ""                  # 可选/Optional
address.pt-BR =        ""                  # 可选/Optional
address.ru =           ""                  # 可选/Optional
address.zh-hans =      ""                  # 可选/Optional
address.zh-hant =      ""                  # 可选/Optional

[[GeoData]]
CIDR =                  "172.20.159.14/32"   # 必选/Required
anycast =               true                 # 可选/Optional | 默认false / example flase
```

### **`[Master]`下的字段解释**

| 字段 | 名称 | 必要性 | 说明 |
| - | - | - | - |
|`CIDR` | 主网段 | 必填 | 为`inetnum`或`inet6num`里的网段 |
| `country.name` | 国家或地区的ISO名称 | 选填 | DN42 registry 允许该项为空值，该项故为选填。若无填写该项则`country.code`无需填写且`fallback_to_master`的值强制为`false`|
| `country.code`| 国家或地区的ISO代码 | 选填 | 如有填写`country.name`则该项为必填|
| `source` | 网段来源 | 必填 | 可填写 `DN42`、`NeoNetwork`、`ICVPN`、`ChaosVPN`、`CRXN` 或其它与 DN42 互联的网络 |

------------

### **`[[GeoData]]`下的字段解释**

| 字段 | 名称 | 必要性 | 说明 |
| - | - | - | - |
| `CIDR` | 网段 | 必填 | 您想赋予以下地理位置信息的网段，网段范围不得大于主网段，IPv4最小为`/32`，IPv6最小为`/128`。 |
| `anycast` | 任播状态 | 选填 | 该字段的值只能为`false`和`true`俩种。`false`表示该网段不是任播网段，`true`则反之，`anycast`的值为`true`时下面的字段失效，即不会处理。不填写或者填写错误则默认为`false`。 |
| `country.name` | 国家或地区的ISO名称 | 必填 | |
| `country.code`| 国家或地区的ISO代码 | 必填 | |
| `region.name` | 一级行政区的名称 | 选填 | 若填写`city`时则该项必填，特殊情况可不填（如中国香港、中国澳门）
| `region.code` | 一级行政区的ISO代码 | 选填 | 若填写`region.name`则该项必填
| city | 城市 | 选填 | |
| latitude | 纬度 | 必填 | 精确到最小行政区即可 |
| longitude | 经度 |必填 | 精确到最小行政区即可 |
| accuracy_radius |经纬度精确半径 | 必填 | 适当填写即可 |

一个`[[GeoData]]`只能同时存在一个`CIRD`的信息。如有多个`CIRD`请创建多个`[[GeoData]]`。

---

#### 关于 试验性 选项
- 如您想提供更精确的地理位置信息或是有意义的备注可在`address.*`字段填写，该字段均为选填。
- **有意义的备注**可以是：主机提供商的信息、该节点在您AS内的类别（边缘节点、骨干网等）、家庭节点的ISP信息等。
- 本库恕不为`address.*`字段提供i18n服务 ~~（虽然国家、城市名称i18n数据仍不完善）~~ ，可自行为`address.*`字段填写各语言的值。
- geofeed 自动更新行为不会删除或修改`address.*`字段，请自行删除或修改并提交 Pull requests 请求。

**注意：不得填写毫无意义或与地理位置信息无关的数据，否则本库会拒绝您的 Pull requests 请求。**

| 字段 | 名称 | 必要性 | 说明 |
| - | - | - | - |
|`address.default` | 默认address | 选填 | 为默认返回值，值可以为任意语言。 |
| `address.de` | 德语address | 选填 | 为德语的返回值，值必须为德语。 |
| `address.en` | 英语address | 选填 | 为英语的返回值，值必须为英语。 |
| `address.es` | 西班牙语address | 选填 | 为西班牙语的返回值，必须为西班牙语。 |
| `address.fr` | 法语address | 选填 | 为法语的返回值，值必须为法语。 |
| `address.ja` | 日语address | 选填 | 为日语的返回值，值必须为日语。 |
| `address.pt-BR` | 巴西葡萄牙语address | 选填 | 为巴西葡萄牙语的返回值，值必须为巴西葡萄牙语。 |
| `address.ru` | 俄语address | 选填 | 为俄语的返回值，值必须为俄语。 |
| `address.zh-hans` | 简体中文address | 选填 | 为简体中文的返回值，值必须为中文。 |
| `address.zh-hans` | 繁体中文address | 选填 | 为繁体中文的返回值，值必须为中文。 |


---

## **提交 Geoip 数据**

本项目支持通过发布的 Geofeed 自动更新数据，也可以手动提交数据。

请注意：**如果您已发布 Geofeed，请勿手动修改数据，会被 Geofeed 数据覆盖。直接修改你发布的 Geofeed 即可。**

### 发布 Geofeed

1. 依照 [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html) 编写 Geofeed CSV 文件
2. 依照 [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html) 将 Geofeed 网址发布到 DN42 Registry
3. 本项目UTC时间每周日0点会自动抓取 Geofeed 文件，更新数据
4. 自动脚本会校验 Geofeed 数据是否合理，不合理的将会丢弃，请按照 [city.csv](./docs/city.csv) 自行检查。
5. 自动脚本不会更改 `address.*` 字段的值，如有需要，请按照 **手动提交** 的方法修改 `address.*` 字段的值.

### 手动提交

1. Fork 本仓库
2. 在 `data/ipv4` 或 `data/ipv6` 文件夹内新建文件。
   文件名格式：使用你的 DN42 网段，将 `/` 替换为 `_`，然后加 `.toml` 后缀
   例如：`172.20.159.0_28.toml`
3. 按照上面的示例来填写数据
4. 填写完成后，执行仓库根目录下的 `datacheck` 二进制可执行单文件，进行自动检查。检查通过即可进行下一步操作
5. 提交时请使用网段 inetnum/inet6num 中任意一个 `mnt-by` 的 **PGP** 或 **SSH** 密钥签名
6. 发起 PR 等待审核合并

---

## **.mmdb 文件结构示例**

```
root@xeiuserver:/opt/dn42/geo-ip-master# mmdblookup --file GeoLite2-City-DN42.mmdb -i 172.20.159.1

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
            "zh-hans": 
              "东京" <utf8_string>
            "zh-hant": 
              "東京" <utf8_string>
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
            "zh-hans": 
              "亚洲" <utf8_string>
            "zh-hant": 
              "亞洲" <utf8_string>
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
            "zh-hans": 
              "日本" <utf8_string>
            "zh-hant": 
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
          1814991 <uint32>
        "iso_code": 
          "CN" <utf8_string>
        "names": 
          {
            "de": 
              "China" <utf8_string>
            "en": 
              "China" <utf8_string>
            "es": 
              "China" <utf8_string>
            "fr": 
              "Chine" <utf8_string>
            "ja": 
              "中国" <utf8_string>
            "pt-BR": 
              "China" <utf8_string>
            "ru": 
              "Китай" <utf8_string>
            "zh-hans": 
              "中国" <utf8_string>
            "zh-hant": 
              "中國" <utf8_string>
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
              "zh-hans": 
                "东京都" <utf8_string>
              "zh-hant": 
                "東京都" <utf8_string>
            }
        }
      ]
    "traits": 
      {
        "is_anycast": 
          false <boolean>
      }
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
