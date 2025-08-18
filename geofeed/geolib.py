import csv
import pickle
import os
from collections import defaultdict

CITY_CSV_FILE = "../docs/city.csv"
GEONAMES_FILE = "allCountries.txt"
CITY_PICKLE = "city_cache.pkl"
GEO_PICKLE = "geonames_cache.pkl"

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
            lat = float(parts[4])
            lon = float(parts[5])
            feature_code = parts[7].strip()
            geonames[(city_name, region_code, country_code)].append((lat, lon))
            if feature_code == "PPLC":
                capitals[country_code] = (lat, lon)
    with open(GEO_PICKLE, "wb") as f:
        pickle.dump((geonames, capitals), f)

if os.path.exists(CITY_PICKLE):
    with open(CITY_PICKLE, "rb") as f:
        country_map, region_map = pickle.load(f)
else:
    country_map = {}
    region_map = {}
    with open(CITY_CSV_FILE, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            country_code = row["country_iso_code"].strip().lower()
            country_name = row["country_name"].strip()
            region_code = row["region_1_iso_code"].strip().lower()
            region_name = row["region_1_name"].strip()
            if country_code not in country_map:
                country_map[country_code] = country_name
            if (country_code, region_code) not in region_map:
                region_map[(country_code, region_code)] = region_name
    with open(CITY_PICKLE, "wb") as f:
        pickle.dump((country_map, region_map), f)

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
