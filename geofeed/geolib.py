import csv
import pickle
import os
from collections import defaultdict

GEOLITE_LOCATIONS_FILE = "../GeoLite2-City-csv/GeoLite2-City-Locations-en.csv"
GEONAMES_FILE = "allCountries.txt"
GEO_PICKLE = "geonames_cache.pkl"
GEOLITE_PICKLE = "geolite_locations_cache.pkl"


def _safe_float(text):
    try:
        return float(text)
    except Exception:
        return 0.0


if os.path.exists(GEO_PICKLE):
    with open(GEO_PICKLE, "rb") as f:
        geonames, capitals = pickle.load(f)
else:
    geonames = defaultdict(list)
    capitals = {}
    with open(GEONAMES_FILE, encoding="utf-8") as f:
        for line in f:
            parts = line.strip().split("\t")
            if len(parts) < 11:
                continue
            city_name = parts[1].strip().lower()
            region_code = parts[10].strip().lower()
            country_code = parts[8].strip().upper()
            lat = _safe_float(parts[4])
            lon = _safe_float(parts[5])
            feature_code = parts[7].strip()
            geonames[(city_name, region_code, country_code)].append((lat, lon))
            if feature_code == "PPLC":
                capitals[country_code] = (lat, lon)
    with open(GEO_PICKLE, "wb") as f:
        pickle.dump((geonames, capitals), f)


def _load_geolite_locations():
    if not os.path.exists(GEOLITE_LOCATIONS_FILE):
        return [], {}, {}, False

    src_mtime = os.path.getmtime(GEOLITE_LOCATIONS_FILE)
    if os.path.exists(GEOLITE_PICKLE):
        try:
            with open(GEOLITE_PICKLE, "rb") as f:
                data = pickle.load(f)
            if isinstance(data, dict) and data.get("mtime") == src_mtime:
                return (
                    data.get("records", []),
                    data.get("country_map", {}),
                    data.get("region_map", {}),
                    data.get("available", False),
                )
        except Exception:
            pass

    records = []
    country_map_local = {}
    region_map_local = {}

    with open(GEOLITE_LOCATIONS_FILE, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            country_code = row.get("country_iso_code", "").strip().upper()
            country_name = row.get("country_name", "").strip()
            sub1_name = row.get("subdivision_1_name", "").strip()
            sub2_name = row.get("subdivision_2_name", "").strip()
            sub1_iso = row.get("subdivision_1_iso_code", "").strip()
            city_name = row.get("city_name", "").strip()
            geoname_id = row.get("geoname_id", "").strip()

            if not country_code or not geoname_id:
                continue

            # Build country map
            if country_name and country_code.lower() not in country_map_local:
                country_map_local[country_code.lower()] = country_name

            # Build region map (both short code and full ISO code as key)
            if sub1_name and sub1_iso:
                short_code = sub1_iso.split("-", 1)[1].strip() if "-" in sub1_iso else sub1_iso
                region_map_local[(country_code.lower(), short_code.lower())] = sub1_name
                region_map_local[(country_code.lower(), sub1_iso.lower())] = sub1_name

            records.append(
                {
                    "country_code": country_code,
                    "city_name": city_name,
                    "sub1": sub1_name,
                    "sub2": sub2_name,
                    "geoname_id": geoname_id,
                }
            )

    available = len(records) > 0
    payload = {
        "mtime": src_mtime,
        "records": records,
        "country_map": country_map_local,
        "region_map": region_map_local,
        "available": available,
    }
    with open(GEOLITE_PICKLE, "wb") as f:
        pickle.dump(payload, f)

    return records, country_map_local, region_map_local, available


geolite_location_records, country_map, region_map, geolite_validation_available = _load_geolite_locations()


def get_location(city, region_code, country_code):
    if city:
        key = (city.strip().lower(), region_code.strip().lower(), country_code.strip().upper())
        geo_list = geonames.get(key, [])
        if geo_list:
            geo = geo_list[0]
            return geo[0], geo[1], True
        for k in geonames:
            if k[0] == city.strip().lower() and k[2] == country_code.strip().upper():
                geo = geonames[k][0]
                return geo[0], geo[1], True
    data = capitals.get(country_code.strip().upper(), (0.0, 0.0))
    return data[0], data[1], False


def validate_geoname_relation(country_code, region_name, city_keyword):
    """
    Validation rule:
    - country: strong match
    - region: strong match against subdivision_1_name or subdivision_2_name
    - city: keyword match (city_name contains keyword, case-insensitive)
    All provided conditions must be satisfied by at least one same geoname record.
    """
    if not geolite_validation_available:
        return True, "validation-skip(no-locations-data)"

    cc = (country_code or "").strip().upper()
    rn = (region_name or "").strip().lower()
    ck = (city_keyword or "").strip().lower()

    if not cc:
        return False, "validation-fail(empty-country)"

    for rec in geolite_location_records:
        if rec["country_code"] != cc:
            continue

        if rn:
            sub1 = (rec["sub1"] or "").strip().lower()
            sub2 = (rec["sub2"] or "").strip().lower()
            if rn != sub1 and rn != sub2:
                continue

        if ck:
            city_name = (rec["city_name"] or "").strip().lower()
            if not city_name or ck not in city_name:
                continue

        return True, rec["geoname_id"]

    return False, "validation-fail(no-matching-geoname)"
