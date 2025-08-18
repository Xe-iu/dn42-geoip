import finder
import geolib
import os
import ipaddress

geofeeds = finder.find_and_clean_geofeed()
for fname, data in geofeeds.items():
    source = data["source"]
    csv_content = data["filtered_csv"]

    netip = fname.split("_")[0]
    netip = ipaddress.ip_address(netip)
    
    if netip.version == 4:
        outpath = "../data/ipv4/" + fname + ".toml"
    else:
        outpath = "../data/ipv6/" + fname + ".toml"
    
    if os.path.exists(outpath):
        os.unlink(outpath)
    
    with open(outpath, "w", encoding="utf-8", newline='\n') as f:
        f.write("# Automatically generated from Geofeed, DO NOT EDIT\n\n")

    for row in csv_content:
        if not row or row[0].startswith("#"):
            continue
        
        prefix, country_code, region, city, *_ = row
        region_code = region.strip()
        try:
            region_code = region.split("-")[1].strip()
        except IndexError:
            pass
        country_name = geolib.country_map.get(country_code.strip().lower(), "")
        region_name = geolib.region_map.get((country_code.strip().lower(), region_code.strip().lower()), "")
        lat, lon, geniune = geolib.get_location(city, region_code, country_code)

        if lat == 0 or lon == 0:
            print(f"{prefix} 位置未识别：{city}, {country_code}，跳过...")
            continue

        if country_name == "" or country_code == "":
            print(f"{prefix} 未知国家, 跳过...")
            continue

        if region_name == "" or region_code == "":
            print(f"{prefix} 未知region，清空数据：{city}, {country_code}")
            region_name = ""
            region_code = ""
            city = ""
        
        if not geniune:
            print(f"{prefix} 无法识别准确位置，回退首都，清理region和city：{city}, {country_code}")
            city = ""
            region_name = ""
            region_code = ""
        
        outinfo = f"[{prefix}]"
        if country_name != "":
            outinfo += f"\ncountry={country_name}"
        if country_code != "":
            outinfo += f"\ncountry_code={country_code}"
        if region_name != "":
            outinfo += f"\nregion={region_name}"
        if region_code != "":
            outinfo += f"\nregion_code={region_code}"
        if city != "":
            outinfo += f"\ncity={city}"
        if lat != 0 or lon != 0:
            outinfo += f"\nlatitude={lat}"
            outinfo += f"\nlongitude={lon}"
            outinfo += "\naccuracy_radius=200"
        outinfo += f"\nsource={source}"

        with open(outpath, "a", encoding="utf-8", newline='\n') as f:
            f.write(outinfo + "\n\n")
