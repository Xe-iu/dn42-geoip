# Geoip-Data Data Structure Explanation

>This article was translated by ChatGPT

-----
## **GeoIP data file naming rules**

Similar to the DN42 registry, the difference is that GeoIP data files use the `.toml` suffix.

Example:
```
CIRD = 172.20.159.0/28
file_name= 172.20.159.0_28.toml
```

For IPv4 prefixes, please create them under `data/ipv4`  
For IPv6 prefixes, please create them under `data/ipv6`

**This GitHub repository cannot be cloned on Windows systems because Windows does not allow the character “:” in file names. Please use a Linux system to clone it.**

------------

## **Field explanation under `[Master]`**

| Field | Name | Required | Description |
| - | - | - | - |
|`CIDR` | Main prefix | Required | The prefix from `inetnum` or `inet6num` |
|`fallback_to_master` | Fallback to main prefix geolocation | Optional | If no specific prefix geolocation is found, fallback to the main prefix’s geolocation. Default is `true` |
| `country.name` | ISO name of country or region | Optional | DN42 registry allows this field to be empty, so it is optional. If not provided, `country.code` is not required and `fallback_to_master` is forced to `false` |
| `country.code`| ISO code of country or region | Optional | Required if `country.name` is provided |
| `source` | Prefix source | Required | Can be `DN42`, `NeoNetwork`, `ICVPN`, `ChaosVPN`, `CRXN`, or other networks interconnected with DN42 |

------------

## **Field explanation under `[[GeoData]]`**

| Field | Name | Required | Description |
| - | - | - | - |
| `CIRD` | Prefix | Required | The prefix to which you want to assign the following geolocation data. The range must not exceed the main prefix. Minimum is `/32` for IPv4 and `/128` for IPv6 |
| `anycast` | Anycast status | Optional | Only `false` or `true`. `false` means not an anycast prefix, `true` means it is. Defaults to `false` if omitted or invalid |
| `country.name` | ISO name of country or region | Required | |
| `country.code`| ISO code of country or region | Required | |
| `region.name` | Name of first-level administrative division | Optional | Required if `city` is provided, except special cases (e.g., Hong Kong, Macau) |
| `region.code` | ISO code of first-level administrative division | Optional | Required if `region.name` is provided |
| city | City | Optional | |
| latitude | Latitude | Required | Accurate to the smallest administrative unit |
| longitude | Longitude | Required | Accurate to the smallest administrative unit |
| accuracy_radius | Accuracy radius | Required | Fill in appropriately |

Each `[[GeoData]]` can only contain one `CIRD`. If there are multiple `CIRD`s, create multiple `[[GeoData]]` entries.

---

### About experimental options
- If you want to provide more precise geolocation information or meaningful notes, you can use the `address.*` fields. These are all optional.
- **Meaningful notes** may include: hosting provider information, node role within your AS (edge node, backbone, etc.), ISP information for home nodes, etc.
- This repository does not provide i18n support for `address.*` fields ~~(although i18n data for country and city names is still incomplete)~~. You may provide values in different languages yourself.
- Automatic geofeed updates will not delete or modify `address.*` fields. Please manually update them and submit Pull Requests if needed.

**Note: Do not include meaningless or unrelated data in `address.*` fields, otherwise your Pull Request will be rejected.**

| Field | Name | Required | Description |
| - | - | - | - |
|`address.default` | Default address | Optional | Default return value, can be in any language |
| `address.de` | German address | Optional | Must be in German |
| `address.en` | English address | Optional | Must be in English |
| `address.es` | Spanish address | Optional | Must be in Spanish |
| `address.fr` | French address | Optional | Must be in French |
| `address.ja` | Japanese address | Optional | Must be in Japanese |
| `address.pt-BR` | Brazilian Portuguese address | Optional | Must be in Brazilian Portuguese |
| `address.ru` | Russian address | Optional | Must be in Russian |
| `address.zh-hans` | Simplified Chinese address | Optional | Must be in Chinese |
| `address.zh-hans` | Traditional Chinese address | Optional | Must be in Chinese |

---

## Partial data sources
- Country and city name data: [maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)