# ***DN42-Geoip Project***

> Data is very limited; contributions from everyone are needed

---

## **Description**

The ISO codes used in this document follow the [ISO3166](https://www.iso.org/iso-3166-country-codes.html) standard, including both two-letter and three-letter codes.

Country/region, first-level administrative division names and ISO codes, and city names can be referred to in [city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv).

This repository builds a new `.mmdb` file every day at 2:00 UTC and publishes it to [Releases](https://github.com/Xe-iu/dn42-geoip/releases).

---

## **Data Structure**

| Field             | Description                                         | Required | Notes                                                                                                |
| ----------------- | --------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------- |
| `country`         | Country or region                                   | Required |                                                                                                      |
| `country_code`    | Country or region ISO code                          | Required |                                                                                                      |
| `region`          | First-level administrative division                 | Optional | Must be provided if `city` is filled; can be omitted in special cases                                |
| `region_code`     | First-level administrative division ISO code        | Optional | Required if `region` is filled                                                                       |
| `city`            | City (usually second-level administrative division) | Optional | Must have `region` when provided, unless no region exists (e.g., Macau)                              |
| `latitude`        | Latitude                                            | Required | Precision up to the smallest administrative division                                                 |
| `longitude`       | Longitude                                           | Required | Precision up to the smallest administrative division                                                 |
| `accuracy_radius` | Latitude/longitude accuracy radius                  | Required | Approximate values are fine; no need for high precision                                              |
| `source`          | Network registration source                         | Required | Can be `DN42`, `NeoNetwork`, `ICVPN`, `ChaosVPN`, `CRXN`, or other networks interconnected with DN42 |

---

## **Example**

```toml
[172.20.159.0/28]             # Entire subnet (main network segment)
country =      "China"        # Country or region as registered in DN42
country_code = "CN"           # ISO code of the country or region
                              # The latitude and longitude of the main network segment do not need to be filled in; others are required
source =       "DN42"         # Required for the largest subnet; optional for others

[172.20.159.1/32]             # Node IP
country =      "Japan"        # Country or region where the node is located
country_code = "JP"           # ISO code of the country or region
region =       "Tokyo"        # First-level administrative division (optional if none)
region_code =  "13"           # ISO code of the first-level administrative division (optional if none)
city =         "Tokyo"        # City (usually second-level administrative division)
latitude =      35.6937632    # Latitude (precision up to your smallest administrative division)
longitude =     139.7036319   # Longitude (precision up to your smallest administrative division)
accuracy_radius=50            # Radius (approximate value is fine)
```

---

## **Submitting Geoip Data**

This project supports automatic updates via published Geofeeds, or manual data submission.

**Note:** If you already published Geofeed, do not manually modify the data; it will be overwritten by Geofeed data. Modify your published Geofeed directly instead.

### Publishing Geofeed

1. Create a Geofeed CSV file according to [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html)
2. Publish the Geofeed URL to the DN42 Registry according to [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html)
3. This project automatically fetches Geofeed file at 0:00 UTC every Sunday

### Manual Submission

1. Fork this repository
2. Create a new file in `data/ipv4` or `data/ipv6` folders and fill in the content
3. File name format: replace `/` in your DN42 subnet with `_` and add `.toml` suffix
   Example: `172.20.159.0_28.toml`
4. When submitting, sign the PR with any **PGP** or **SSH** key listed in the `mnt-by` field of the subnet
5. Open a PR and wait for review and merging

---

## **.mmdb File Structure Example**

```
root@xeiuserver:/opt/dn42/geo-ip-master# mmdblookup --file GeoLite2-City-DN42.mmdb -i fd43:83b9:82e2:face::

  {
    "city": 
      {
        "names": 
          {
            "de": "Tokio" <utf8_string>
            "en": "Tokyo" <utf8_string>
            "es": "Tokio" <utf8_string>
            "fr": "Tokyo" <utf8_string>
            "ja": "東京" <utf8_string>
            "pt-BR": "Tóquio" <utf8_string>
            "ru": "Токио" <utf8_string>
            "zh-CN": "东京" <utf8_string>
          }
      }
    "continent": 
      {
        "code": "AS" <utf8_string>
        "geoname_id": 6255147 <uint32>
        "names": 
          {
            "de": "Asien" <utf8_string>
            "en": "Asia" <utf8_string>
            "es": "Asia" <utf8_string>
            "fr": "Asie" <utf8_string>
            "ja": "アジア" <utf8_string>
            "pt-BR": "Ásia" <utf8_string>
            "ru": "Азия" <utf8_string>
            "zh-CN": "亚洲" <utf8_string>
          }
      }
    "country": 
      {
        "geoname_id": 1850147 <uint32>
        "iso_code": "JP" <utf8_string>
        "names": 
          {
            "de": "Japan" <utf8_string>
            "en": "Japan" <utf8_string>
            "es": "Japón" <utf8_string>
            "fr": "Japon" <utf8_string>
            "ja": "日本" <utf8_string>
            "pt-BR": "Japão" <utf8_string>
            "ru": "Япония" <utf8_string>
            "zh-CN": "日本" <utf8_string>
          }
      }
    "location": 
      {
        "accuracy_radius": 50 <uint16>
        "latitude": 35.693763 <double>
        "longitude": 139.703632 <double>
        "time_zone": "Asia/Tokyo" <utf8_string>
      }
    "registered_country": 
      {
        "geoname_id": 1861060 <uint32>
        "iso_code": "JP" <utf8_string>
        "names": 
          {
            "de": "Japan" <utf8_string>
            "en": "Japan" <utf8_string>
            "es": "Japón" <utf8_string>
            "fr": "Japon" <utf8_string>
            "ja": "日本" <utf8_string>
            "pt-BR": "Japão" <utf8_string>
            "ru": "Япония" <utf8_string>
            "zh-CN": "日本" <utf8_string>
          }
      }
    "subdivisions": 
      [
        {
          "names": 
            {
              "de": "Tokio" <utf8_string>
              "en": "Tokyo" <utf8_string>
              "es": "Tokio" <utf8_string>
              "fr": "Préfecture de Tokyo" <utf8_string>
              "ja": "東京都" <utf8_string>
              "pt-BR": "Tóquio" <utf8_string>
              "ru": "Токио" <utf8_string>
              "zh-CN": "东京都" <utf8_string>
            }
        }
      ]
  }
```

---

## **Manually Generating `.mmdb` Files**

1. Install dependencies:

```bash
sudo apt install libmaxmind-db-writer-perl
curl -L https://cpanm.pm/Cpanm/install | perl - -install
cpanm Net::Works::Network Text::CSV
```

2. Clone the repository:

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip
```

3. Convert TOML to CSV:

```bash
./toml2csv
```

4. Generate the `.mmdb` file:

```bash
perl build_mmdb.pl
```

5. After success, `GeoLite2-City-DN42.mmdb` will be in the root directory

---

## **Data Sources**

* Country and city name data: [maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)
