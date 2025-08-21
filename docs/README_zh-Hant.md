# ***DN42-Geoip 項目***

> 數據非常稀少,歡迎大家一起貢獻

---

## **說明**


本文中使用的 ISO 編碼遵循 [ISO3166](https://www.iso.org/iso-3166-country-codes.html) 標準,包含二位字母碼與三位字母碼.

國家/地區、第一級行政區名稱及 ISO 編碼,城市名稱可參考：[city.csv](https://github.com/Xe-iu/dn42-geoip/blob/main/docs/city.csv).

本倉庫會於每日 UTC 時間凌晨 2 點構建新的 `.mmdb` 檔案並發布到 [Releases](https://github.com/Xe-iu/dn42-geoip/releases).

---

## **數據結構**

| 欄位                | 說明                   | 必要性 | 備註                                                                 |
| ----------------- | -------------------- | --- | ------------------------------------------------------------------ |
| `country`         | 國家或地區                | 必填  |                                                                    |
| `country_code`    | 國家或地區 ISO 代碼         | 必填  |                                                                    |
| `region`          | 第一級行政區               | 選填  | 若填寫 `city` 則必須有 `region`；特殊情況可省略                        |
| `region_code`     | 第一級行政區 ISO 代碼        | 選填  | 若填寫 `region` 則必填                                                |
| `city`            | 城市（通常為第二級行政區）     | 選填  | 若填寫 `city` 則必須有 `region`,除非該地無第一級行政區（例如澳門）           |
| `latitude`        | 緯度                     | 必填  | 精確到最小行政區即可                                                    |
| `longitude`       | 經度                     | 必填  | 精確到最小行政區即可                                                    |
| `accuracy_radius` | 經緯度精確半徑（公尺或公里視情況） | 必填  | 適度填寫即可,不需要過度精確                                               |
| `source`          | 網段註冊來源                | 必填  | 可填 `DN42`、`NeoNetwork`、`ICVPN`、`ChaosVPN`、`CRXN` 或其他與 DN42 互聯的網路 |

---

## **示例**

```toml
[172.20.159.0/28]			      # 整個網段（主網段）
country =      "China"		      # 在 DN42 註冊時所填寫的國家或地區
country_code = "CN"			      # 國家或地區的 ISO 代碼
                                  # 這裡的經緯度可不填,其它為必填
source =       "DN42"		      # 在最大網段時為必填,其它情況可選填.

[172.20.159.1/32]			      # 節點 IP
country =      "Japan"		      # 節點所在的國家或地區
country_code = "JP"			      # 國家或地區的 ISO 代碼
region =       "Tokyo"		      # 所在的第一級行政區（無則可不寫）
region_code =  "13"			      # 該第一級行政區的 ISO 代碼（無則可不寫）
city =         "Tokyo"		      # 所在城市（通常為第二級行政區）
latitude =      35.6937632	      # 緯度（精確到你所填寫的最小行政區即可）
longitude =     139.7036319	      # 經度（精確到你所填寫的最小行政區即可）
accuracy_radius=50			      # 半徑（隨意填寫）
```

---

## **提交 Geoip 數據**

本項目支援透過已發布的 Geofeed 自動更新數據,也可以手動提交數據.

請注意：**如果您已發布 Geofeed,請勿手動修改數據,會被 Geofeed 數據覆蓋.請直接修改您發布的 Geofeed.**

### 發布 Geofeed

1. 依據 [RFC 8805](https://www.rfc-editor.org/rfc/rfc8805.html) 編寫 Geofeed CSV 檔案.  
2. 依據 [RFC 9632](https://www.rfc-editor.org/rfc/rfc9632.html) 將 Geofeed 網址發布到 DN42 Registry.  
3. 本項目會在 UTC 時間每週日 00:00 自動抓取 Geofeed 檔案並更新數據.

### 手動提交

1. Fork 本倉庫.  
2. 在 `data/ipv4` 或 `data/ipv6` 數據夾內新建檔案並填寫內容.  
3. 檔名格式：使用你的 DN42 網段,將 `/` 替換為 `_`,然後加上 `.toml` 副檔名.例如：`172.20.159.0_28.toml`.  
4. 提交時請使用網段 inetnum/inet6num 中任一個 `mnt-by` 的 **PGP** 或 **SSH** 金鑰簽名.  
5. 發起 Pull Request,等待審核與合併.

---

## **.mmdb 檔案結構示例**

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

## **手動產生 `.mmdb` 檔案**

1. 安裝相依套件：

```bash
sudo apt install libmaxmind-db-writer-perl
curl -L https://cpanm.pm/Cpanm/install | perl - -install
cpanm Net::Works::Network Text::CSV
```

2. 複製（clone）倉庫：

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip
```

3. 將 TOML 轉成 CSV：

```bash
./toml2csv
```

4. 生成 `.mmdb` 檔案：

```bash
perl build_mmdb.pl
```

5. 成功後會在項目根目錄得到 `GeoLite2-City-DN42.mmdb` 檔案.

---

## **數據來源**

* 國家、城市名稱數據來源：[maxmind-geoip](https://github.com/8bitsaver/maxmind-geoip)
