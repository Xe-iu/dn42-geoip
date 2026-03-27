#Geoip-Data 数据结构解释
##**geoip数据文件命名规则**
与 DN42 registry 的差不多一致，区别在于geoip数据文件的名称后缀为`.toml`

示例：
```
CIRD = 172.20.159.0/28
file_name= 172.20.159.0_28.toml
```

IPv4网段请到`data/ipv4`创建
IPv6网段请到`data/ipv6`创建

**在Windows系统上无法拉取该github仓库，因为Windows系统不允许文件名中存在字符“:”。请使用Linux系统拉取。**

------------

##** `[Master]`下的字段解释**

| 字段 | 名称 | 必要性 | 说明 |
| - | - | - | - |
|`CIDR` | 主网段 | 必填 | 为`inetnum`或`inet6num`里的网段 |
|`fallback_to_master` | 默认返回主网段的地理位置信息 | 选填 | 在未查询到具体网段的地理位置信息时默认返回主网段的地理位置信息，默认值为`true` |
| `country.name` | 国家或地区的ISO名称 | 选填 | DN42 registry 允许该项为空值，该项故为选填。若无填写该项则`country.code`无需填写且`fallback_to_master`的值强制为`false`|
| `country.code`| 国家或地区的ISO代码 | 选填 | 如有填写`country.name`则该项为必填|
| `source` | 网段来源 | 必填 | 可填写 `DN42`、`NeoNetwork`、`ICVPN`、`ChaosVPN`、`CRXN` 或其它与 DN42 互联的网络 |

------------


##** `[[GeoData]]`下的字段解释**

| 字段 | 名称 | 必要性 | 说明 |
| - | - | - | - |
| `CIRD` | 网段 | 必填 | 您想赋予以下地理位置信息的网段，网段范围不得大于主网段，IPv4最小为`/32`，IPv6最小为`/128`。 |
| `anycast` | 任播状态 | 选填 | 该字段的值只能为`false`和`true`俩种。`false`表示该网段不是仁播网段，`true`则反之。不填写或者填写错误则默认为`false`。 |
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
###关于 试验性 选项
- 如您想提供更精确的地理位置信息或是有意义的备注可在`address.*`字段填写，该字段均为选填。
- **有意义的备注**可以是：主机提供商的信息、该节点在您AS内的类别（边缘节点、骨干网等）、家庭节点的ISP信息等。
- 本库恕不为`address.*`字段提供i18n服务~~（虽然国家、城市名称i18n数据仍不完善）~~，可自行为`address.*`字段填写各语言的值。
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
##部分数据来源
- 国家、城市名称数据：[maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)
