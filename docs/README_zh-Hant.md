# ***DN42-Geoip專案***

> 數據非常少，需要大家一起貢獻

---

## **說明**

[English](./README_en-US.md)
[简体中文](../README.md)

本文中使用的 ISO 編碼遵循 [ISO3166](https://www.iso.org/iso-3166-country-codes.html) 標準，包含二位字母碼和三位字母碼。

國家/地區、第一級行政區名稱及 ISO 編碼，城市名稱可參考：[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv)。

本倉庫每天 UTC 時間凌晨 2 點構建新的 `.mmdb` 檔案並發布到 [Releases](https://github.com/Xe-iu/dn42-geoip/releases)。

---

## **geoip 數據檔命名規則**

與 DN42 registry 大致一致，區別在於 geoip 數據檔的名稱後綴為 `.toml`

範例：

```
CIDR = 172.20.159.0/28
file_name= 172.20.159.0_28.toml
```

IPv4 網段請到 `data/ipv4` 建立
IPv6 網段請到 `data/ipv6` 建立

**在 Windows 系統上無法拉取該 GitHub 倉庫，因為 Windows 系統不允許檔名中存在字元「:」。請使用 Linux 系統拉取。**

---

## **範例**

[數據結構範例](../example.geoip-data.toml)

```toml
[Version]
data_version =     "1.1"                    # 數據結構版本號
create_time  = 2025-12-31T11:45:14Z         # 建立時間 (UTC | yyyy-mm-ddThh:mm:ssZ)
update_time  = 2025-12-31T11:45:14Z         # 最近修改時間 (UTC | yyyy-mm-ddThh:mm:ssZ)

[Master]
CIDR =                  "172.20.159.0/28"   # 必填 / Required
fallback_to_master =    false               # 選填 / Optional | 預設為 true / example true
country.name =          "China"             # 選填 / Optional | 若未填寫則 fallback_to_master 強制為 false
country.code =          "CN"                # 選填 / Optional
source =                "DN42"              # 必填 / Required | 可為 DN42、NeoNetwork、ICVPN、ChaosVPN、CRXN 或其他與 DN42 互聯的網路

[[GeoData]]
CIDR =                  "172.20.159.1/32"   # 必填 / Required
anycast =               false               # 選填 / Optional | 預設 false
country.name =          "Japan"             # 必填 / Required
country.code =          "JP"                # 必填 / Required
region.name =           "Tokyo"             # 選填 / Optional
region.code =           "13"                # 選填 / Optional
city =                  "Tokyo"             # 選填 / Optional
latitude =              35.6937632          # 必填 / Required
longitude =             139.7036319         # 必填 / Required
accuracy_radius=        50                  # 必填 / Required

# 試驗性 / Experimental
address.default =      ""                  # 選填 / Optional
address.de =           ""                  # 選填 / Optional
address.en =           ""                  # 選填 / Optional
address.es =           ""                  # 選填 / Optional
address.fr =           ""                  # 選填 / Optional
address.ja =           ""                  # 選填 / Optional
address.pt-BR =        ""                  # 選填 / Optional
address.ru =           ""                  # 選填 / Optional
address.zh-hans =      ""                  # 選填 / Optional
address.zh-hant =      ""                  # 選填 / Optional

[[GeoData]]
CIDR =                  "172.20.159.14/32"   # 必填 / Required
anycast =               true                 # 選填 / Optional
```

---

### **`[Master]`下的欄位解釋**

| 欄位                   | 名稱             | 必要性 | 說明                                                                                            |
| -------------------- | -------------- | --- | --------------------------------------------------------------------------------------------- |
| `CIDR`               | 主網段            | 必填  | 為 `inetnum` 或 `inet6num` 裡的網段                                                                 |
| `fallback_to_master` | 預設返回主網段的地理位置信息 | 選填  | 在未查詢到具體網段的地理位置信息時，預設返回主網段的地理位置信息，預設值為 `true`                                                  |
| `country.name`       | 國家或地區的 ISO 名稱  | 選填  | DN42 registry 允許該項為空值，因此為選填。若未填寫該項，則 `country.code` 無需填寫，且 `fallback_to_master` 的值強制為 `false` |
| `country.code`       | 國家或地區的 ISO 代碼  | 選填  | 如有填寫 `country.name`，則該項為必填                                                                    |
| `source`             | 網段來源           | 必填  | 可填寫 `DN42`、`NeoNetwork`、`ICVPN`、`ChaosVPN`、`CRXN` 或其他與 DN42 互聯的網路                             |

---

### **`[[GeoData]]`下的欄位解釋**

| 欄位                | 名稱            | 必要性 | 說明                                                                                                                 |
| ----------------- | ------------- | --- | ------------------------------------------------------------------------------------------------------------------ |
| `CIDR`            | 網段            | 必填  | 您想賦予以下地理位置信息的網段，網段範圍不得大於主網段，IPv4 最小為 `/32`，IPv6 最小為 `/128`                                                         |
| `anycast`         | 任播狀態          | 選填  | 該欄位的值只能為 `false` 或 `true`。`false` 表示該網段不是任播網段，`true` 則相反。當 `anycast` 為 `true` 時，下方欄位將失效（不會處理）。未填寫或填寫錯誤則預設為 `false` |
| `country.name`    | 國家或地區的 ISO 名稱 | 必填  |                                                                                                                    |
| `country.code`    | 國家或地區的 ISO 代碼 | 必填  |                                                                                                                    |
| `region.name`     | 一級行政區名稱       | 選填  | 若填寫 `city`，則該項為必填；特殊情況可不填（如中國香港、中國澳門）                                                                              |
| `region.code`     | 一級行政區的 ISO 代碼 | 選填  | 若填寫 `region.name`，則該項為必填                                                                                           |
| `city`            | 城市            | 選填  |                                                                                                                    |
| `latitude`        | 緯度            | 必填  | 精確到最小行政區即可                                                                                                         |
| `longitude`       | 經度            | 必填  | 精確到最小行政區即可                                                                                                         |
| `accuracy_radius` | 經緯度精確半徑       | 必填  | 視情況適當填寫                                                                                                            |

一個 `[[GeoData]]` 只能同時存在一個 `CIDR` 的資訊。如有多個 `CIDR`，請建立多個 `[[GeoData]]`。

----

#### 關於 試驗性 選項

* 如您想提供更精確的地理位置信息或是有意義的備註，可在 `address.*` 欄位填寫，該欄位均為選填。
* **有意義的備註** 可以是：主機提供商的資訊、該節點在您 AS 內的類別（邊緣節點、骨幹網等）、家庭節點的 ISP 資訊等。
* 本庫恕不為 `address.*` 欄位提供 i18n 服務 ~~（雖然國家、城市名稱 i18n 資料仍不完善）~~，可自行為 `address.*` 欄位填寫各語言的值。
* geofeed 自動更新行為不會刪除或修改 `address.*` 欄位，請自行刪除或修改並提交 Pull requests 請求。

**注意：不得填寫毫無意義或與地理位置信息無關的資料，否則本庫會拒絕您的 Pull requests 請求。**

| 欄位                | 名稱             | 必要性 | 說明                      |
| ----------------- | -------------- | --- | ----------------------- |
| `address.default` | 預設 address     | 選填  | 為預設返回值，值可以為任意語言。        |
| `address.de`      | 德語 address     | 選填  | 為德語的返回值，值必須為德語。         |
| `address.en`      | 英語 address     | 選填  | 為英語的返回值，值必須為英語。         |
| `address.es`      | 西班牙語 address   | 選填  | 為西班牙語的返回值，值必須為西班牙語。     |
| `address.fr`      | 法語 address     | 選填  | 為法語的返回值，值必須為法語。         |
| `address.ja`      | 日語 address     | 選填  | 為日語的返回值，值必須為日語。         |
| `address.pt-BR`   | 巴西葡萄牙語 address | 選填  | 為巴西葡萄牙語的返回值，值必須為巴西葡萄牙語。 |
| `address.ru`      | 俄語 address     | 選填  | 為俄語的返回值，值必須為俄語。         |
| `address.zh-hans` | 簡體中文 address   | 選填  | 為簡體中文的返回值，值必須為中文。       |
| `address.zh-hant` | 繁體中文 address   | 選填  | 為繁體中文的返回值，值必須為中文。       |

----

## **.mmdb 文件結構範例**

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

---

## **提交 Geoip 數據**

支援 Geofeed 或手動提交。

⚠️ 若使用 Geofeed，請勿手動修改。

---

## **提交 GeoIP 資料**

本專案支援透過已發布的 Geofeed 自動更新資料，也可以手動提交資料。

請注意：**如果您已發布 Geofeed，請勿手動修改資料，否則會被 Geofeed 資料覆蓋。請直接修改您所發布的 Geofeed 即可。**

### 發布 Geofeed

1. 依照 [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html) 編寫 Geofeed CSV 檔案
2. 依照 [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html) 將 Geofeed 網址發布到 DN42 Registry
3. 本專案於 UTC 時間每週日 0 點會自動抓取 Geofeed 檔案並更新資料
4. 自動腳本會檢查 Geofeed 資料是否合理，不合理的資料將會被丟棄，請依照 [city.csv](./docs/city.csv) 自行檢查
5. 自動腳本不會更改 `address.*` 欄位的值，如有需要，請依照 **手動提交** 的方式修改 `address.*` 欄位的值

### 手動提交

1. Fork 本倉庫
2. 在 `data/ipv4` 或 `data/ipv6` 資料夾內建立新檔案
   檔名格式：使用您的 DN42 網段，將 `/` 替換為 `_`，再加上 `.toml` 副檔名
   例如：`172.20.159.0_28.toml`
3. 依照上述範例填寫資料
4. 填寫完成後，執行倉庫根目錄下的 `datacheck` 可執行檔進行自動檢查，檢查通過後即可進行下一步
5. 提交時請使用網段 inetnum/inet6num 中任一 `mnt-by` 的 **PGP** 或 **SSH** 金鑰進行簽名
6. 發起 PR 並等待審核合併

----

## **手動生成 `.mmdb`**

1. 安裝依賴

```bash
sudo apt install libmaxmind-db-writer-perl
curl -L https://cpanm.pm/Cpanm/install | perl - -install
cpanm Net::Works::Network Text::CSV
```

2. 克隆倉庫

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip
```

3. 轉換

```bash
./toml2csv
```

4. 建立 mmdb

```bash
perl build_mmdb.pl
```

5. 完成

---

## **數據來源**

* 國家、城市資料：[maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)

---

