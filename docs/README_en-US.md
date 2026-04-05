# ***DN42-Geoip Project***

> The dataset is very limited — contributions from everyone are welcome.

---

## **Description**

[简体中文](../README.md)
[繁体中文](./README_zh-Hant.md)

The ISO codes used in this document follow the [ISO 3166](https://www.iso.org/iso-3166-country-codes.html) standard, including both alpha-2 and alpha-3 country codes.

For country/region names, first-level administrative divisions, ISO codes, and city names, please refer to:
[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv)

This repository builds a new `.mmdb` file daily at 02:00 UTC and publishes it to:
[Releases](https://github.com/Xe-iu/dn42-geoip/releases)

---

## **GeoIP Data File Naming Rules**

Similar to the DN42 registry, but GeoIP data files use the `.toml` extension.

Example:

```
CIDR = 172.20.159.0/28
file_name = 172.20.159.0_28.toml
```

* For IPv4 ranges, create files under `data/ipv4`
* For IPv6 ranges, create files under `data/ipv6`

**Note:** On Windows systems, this repository cannot be cloned because Windows does not allow the character “:” in file names. Please use a Linux system to clone the repository.

---

## **Example**

[Data Structure Example](../example.geoip-data.toml)

```toml
[Version]
data_version =     "1.1"                    # Data structure version
create_time  = 2025-12-31T11:45:14Z         # Creation time (UTC | yyyy-mm-ddThh:mm:ssZ)
update_time  = 2025-12-31T11:45:14Z         # Last update time (UTC | yyyy-mm-ddThh:mm:ssZ)

[Master]
CIDR =                  "172.20.159.0/28"   # Required
fallback_to_master =    false               # Optional | Default is true
country.name =          "China"             # Optional | If not set, fallback_to_master is forced to false
country.code =          "CN"                # Optional
source =                "DN42"              # Required | Can be DN42, NeoNetwork, ICVPN, ChaosVPN, CRXN, or other networks interconnected with DN42

[[GeoData]]
CIDR =                  "172.20.159.1/32"   # Required
anycast =               false               # Optional | Default false
country.name =          "Japan"             # Required
country.code =          "JP"                # Required
region.name =           "Tokyo"             # Optional
region.code =           "13"                # Optional
city =                  "Tokyo"             # Optional
latitude =              35.6937632          # Required
longitude =             139.7036319         # Required
accuracy_radius=        50                  # Required

# Experimental
address.default =      ""                  # Optional
address.de =           ""                  # Optional
address.en =           ""                  # Optional
address.es =           ""                  # Optional
address.fr =           ""                  # Optional
address.ja =           ""                  # Optional
address.pt-BR =        ""                  # Optional
address.ru =           ""                  # Optional
address.zh-hans =      ""                  # Optional
address.zh-hant =      ""                  # Optional

[[GeoData]]
CIDR =                  "172.20.159.14/32"   # Required
anycast =               true                 # Optional | Default false
```

---

## **Field description under `[Master]`**

| Field                | Name                           | Required | Description                                                                                                                          |
| -------------------- | ------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `CIDR`               | Primary network                | Required | The network range from `inetnum` or `inet6num`                                                                                       |
| `fallback_to_master` | Fallback to master geolocation | Optional | If no specific geolocation is found, return the master network’s geolocation. Default is `true`.                                     |
| `country.name`       | Country/region ISO name        | Optional | DN42 registry allows this field to be empty. If empty, `country.code` is not required and `fallback_to_master` is forced to `false`. |
| `country.code`       | Country/region ISO code        | Optional | Required if `country.name` is provided                                                                                               |
| `source`             | Network source                 | Required | Can be `DN42`, `NeoNetwork`, `ICVPN`, `ChaosVPN`, `CRXN`, or other DN42-connected networks                                           |

---

## **Field description under `[[GeoData]]`**

| Field             | Name                              | Required | Description                                                                                                               |
| ----------------- | --------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------- |
| `CIDR`            | Network range                     | Required | The network range to assign geolocation to. Must not exceed the master range. Minimum `/32` for IPv4 and `/128` for IPv6. |
| `anycast`         | Anycast status                    | Optional | Must be `true` or `false`. If `true`, all other fields are ignored. Default is `false` if omitted or invalid.             |
| `country.name`    | Country/region ISO name           | Required |                                                                                                                           |
| `country.code`    | Country/region ISO code           | Required |                                                                                                                           |
| `region.name`     | First-level administrative region | Optional | Required if `city` is specified (except special cases like Hong Kong or Macau)                                            |
| `region.code`     | Region ISO code                   | Optional | Required if `region.name` is specified                                                                                    |
| `city`            | City                              | Optional |                                                                                                                           |
| `latitude`        | Latitude                          | Required | Accurate to the smallest administrative division                                                                          |
| `longitude`       | Longitude                         | Required | Accurate to the smallest administrative division                                                                          |
| `accuracy_radius` | Accuracy radius                   | Required | Reasonable estimate                                                                                                       |

A single `[[GeoData]]` block can only contain one `CIDR`. For multiple CIDRs, create multiple `[[GeoData]]` blocks.

---

## **About Experimental Options**

* If you want to provide more precise location details or meaningful notes, you can use the `address.*` fields. These are all optional.
* **Meaningful notes** may include: hosting provider info, node role within your AS (edge, backbone, etc.), ISP info for home nodes, etc.
* This repository does not provide i18n support for `address.*` fields. You may manually provide values in different languages.
* The geofeed auto-update process will not modify or remove `address.*` fields. Please update or delete them manually via Pull Requests.

**Note: Do not include meaningless or irrelevant data. Otherwise, your Pull Request will be rejected.**

| Field             | Name                         | Required | Description                                  |
| ----------------- | ---------------------------- | -------- | -------------------------------------------- |
| `address.default` | Default address              | Optional | Default return value, can be in any language |
| `address.de`      | German address               | Optional | Must be in German                            |
| `address.en`      | English address              | Optional | Must be in English                           |
| `address.es`      | Spanish address              | Optional | Must be in Spanish                           |
| `address.fr`      | French address               | Optional | Must be in French                            |
| `address.ja`      | Japanese address             | Optional | Must be in Japanese                          |
| `address.pt-BR`   | Brazilian Portuguese address | Optional | Must be in Brazilian Portuguese              |
| `address.ru`      | Russian address              | Optional | Must be in Russian                           |
| `address.zh-hans` | Simplified Chinese address   | Optional | Must be in Simplified Chinese                |
| `address.zh-hant` | Traditional Chinese address  | Optional | Must be in Traditional Chinese               |


---

## **Submitting GeoIP Data**

This project supports automatic updates via published Geofeed, and also allows manual data submission.

**Note:** If you have already published a Geofeed, please do not manually modify the data, as it will be overwritten by the Geofeed. Instead, update your published Geofeed directly.

### Publishing a Geofeed

1. Create a Geofeed CSV file according to [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html)
2. Publish the Geofeed URL to the DN42 Registry following [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html)
3. This project automatically fetches the Geofeed file and updates data every Sunday at 00:00 UTC
4. The automated script validates the Geofeed data; invalid entries will be discarded. Please verify your data using [city.csv](./docs/city.csv)
5. The automated script will not modify the `address.*` fields. If changes are needed, use the **Manual Submission** method to update those fields

### Manual Submission

1. Fork this repository
2. Create a new file in the `data/ipv4` or `data/ipv6` directory

   * File naming format: use your DN42 subnet, replace `/` with `_`, and add the `.toml` extension
   * Example: `172.20.159.0_28.toml`
3. Fill in the data following the provided examples
4. After completing the file, run the `datacheck` binary executable in the repository root for automatic validation. If it passes, proceed to the next step
5. When submitting, sign the commit using a **PGP** or **SSH** key from any `mnt-by` field in the inetnum/inet6num record
6. Open a PR and wait for review and merge

---

## **`.mmdb` Structure Example**

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

## **Manually Generate `.mmdb`**

### 1. Install dependencies

```bash
sudo apt install libmaxmind-db-writer-perl
curl -L https://cpanm.pm/Cpanm/install | perl - -install
cpanm Net::Works::Network Text::CSV
```

### 2. Clone repository

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip
```

### 3. Convert TOML to CSV

```bash
./toml2csv
```

### 4. Build `.mmdb`

```bash
perl build_mmdb.pl
```

### 5. Output

`GeoLite2-City-DN42.mmdb` will be generated in the root directory.

---

## **Data Sources**

* Country and city names:
  [https://github.com/8bitsaver/maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)
