import finder
import geolib
import os
import ipaddress
from datetime import datetime, timezone
from collections import OrderedDict


def toml_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def fmt_float(value: float) -> str:
    text = f"{value:.8f}".rstrip("0").rstrip(".")
    return text if text else "0"


def parse_toml_value(value: str) -> str:
    v = value.strip()
    if len(v) >= 2 and v[0] == '"' and v[-1] == '"':
        v = v[1:-1]
        v = v.replace('\\"', '"').replace("\\\\", "\\")
    return v


def load_existing_create_time(outpath):
    if not os.path.exists(outpath):
        return ""

    in_version = False
    with open(outpath, "r", encoding="utf-8", errors="ignore") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue

            if line == "[Version]":
                in_version = True
                continue
            if line.startswith("[") and line.endswith("]") and line != "[Version]":
                in_version = False
                continue

            if not in_version or "=" not in line:
                continue

            key, raw_value = line.split("=", 1)
            if key.strip() == "create_time":
                return parse_toml_value(raw_value)

    return ""


def load_existing_addresses(outpath):
    """
    Parse existing TOML and return:
      { cidr: OrderedDict({"address.default": "...", ...}) }
    """
    result = {}
    if not os.path.exists(outpath):
        return result

    current_cidr = None
    in_geodata = False

    with open(outpath, "r", encoding="utf-8", errors="ignore") as f:
        for raw in f:
            line = raw.strip()
            if not line or line.startswith("#"):
                continue

            if line == "[[GeoData]]":
                in_geodata = True
                current_cidr = None
                continue

            if line.startswith("[") and line.endswith("]") and line != "[[GeoData]]":
                in_geodata = False
                current_cidr = None
                continue

            if not in_geodata or "=" not in line:
                continue

            key, raw_value = line.split("=", 1)
            key = key.strip()
            value = parse_toml_value(raw_value)

            if key == "CIDR":
                current_cidr = value
                if current_cidr not in result:
                    result[current_cidr] = OrderedDict()
                continue

            if key.startswith("address.") and current_cidr:
                result[current_cidr][key] = value

    return result


def sort_address_items(addresses: OrderedDict):
    preferred = [
        "address.default",
        "address.de",
        "address.en",
        "address.es",
        "address.fr",
        "address.ja",
        "address.pt-BR",
        "address.ru",
        "address.zh-hans",
        "address.zh-hant",
    ]
    output = []
    for key in preferred:
        if key in addresses:
            output.append((key, addresses[key]))
    for key, value in addresses.items():
        if key not in preferred:
            output.append((key, value))
    return output


def build_version_and_master_text(master_cidr, source, master_country_code, existing_create_time):
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    create_time = existing_create_time if existing_create_time else now

    country_code = (master_country_code or "").strip().upper()
    country_name = geolib.country_map.get(country_code.lower(), "") if country_code else ""

    lines = [
        "[Version]",
        'data_version = "1.1"',
        f"create_time = {create_time}",
        f"update_time = {now}",
        "",
        "[Master]",
        f'CIDR = "{toml_escape(master_cidr)}"',
    ]

    if country_name:
        lines.append(f'country.name = "{toml_escape(country_name)}"')
    if country_code:
        lines.append(f'country.code = "{toml_escape(country_code)}"')

    if source:
        lines.append(f'source = "{toml_escape(source)}"')
    else:
        lines.append('source = "DN42"')

    lines.append("")
    return "\n".join(lines)


def build_geo_row(row, ip_version):
    if not row or row[0].startswith("#"):
        return None

    prefix, country_code, region, city, *_ = row
    prefix = prefix.strip()
    country_code = country_code.strip().upper()
    region = region.strip()
    city = city.strip()

    if "/" not in prefix:
        prefix = f"{prefix}/32" if ip_version == 4 else f"{prefix}/128"

    region_code = region
    if "-" in region:
        parts = region.split("-", 1)
        region_code = parts[1].strip()

    country_name = geolib.country_map.get(country_code.lower(), "")
    region_name = geolib.region_map.get((country_code.lower(), region_code.lower()), "")

    lat, lon, genuine = geolib.get_location(city, region_code, country_code)
    if lat == 0 or lon == 0:
        print(f"{prefix} location unresolved: {city}, {country_code}, skipping")
        return None

    if not country_name or not country_code:
        print(f"{prefix} unknown country, skipping")
        return None

    # Keep Hong Kong/Macau-like special cases (region may be empty).
    if not region_name or not region_code:
        region_name = ""
        region_code = ""

    # Fallback to country-level location when city-level location is not genuine.
    if not genuine:
        city = ""
        region_name = ""
        region_code = ""

    valid, info = geolib.validate_geoname_relation(country_code, region_name, city)
    if not valid:
        print(f"{prefix} geoname relation invalid ({info}), skipping")
        return None

    return {
        "cidr": prefix,
        "country_name": country_name,
        "country_code": country_code,
        "region_name": region_name,
        "region_code": region_code,
        "city": city,
        "latitude": lat,
        "longitude": lon,
        "accuracy_radius": 50,
        "anycast": False,
    }


def build_geodata_text(geo, existing_addresses):
    lines = [
        "[[GeoData]]",
        f'CIDR = "{toml_escape(geo["cidr"])}"',
        f'anycast = {"true" if geo["anycast"] else "false"}',
        f'country.name = "{toml_escape(geo["country_name"])}"',
        f'country.code = "{toml_escape(geo["country_code"])}"',
    ]

    if geo["region_name"]:
        lines.append(f'region.name = "{toml_escape(geo["region_name"])}"')
    if geo["region_code"]:
        lines.append(f'region.code = "{toml_escape(geo["region_code"])}"')
    if geo["city"]:
        lines.append(f'city = "{toml_escape(geo["city"])}"')

    lines.append(f'latitude = {fmt_float(geo["latitude"])}')
    lines.append(f'longitude = {fmt_float(geo["longitude"])}')
    lines.append(f'accuracy_radius = {geo["accuracy_radius"]}')

    if existing_addresses:
        lines.append("# The above information is automatically generated from the geofeed, DO NOT EDIT")
        for key, value in sort_address_items(existing_addresses):
            lines.append(f'{key} = "{toml_escape(value)}"')

    lines.append("")
    return "\n".join(lines)


def render_file_content(master_cidr, source, master_country_code, csv_content, ip_version, address_map, existing_create_time):
    blocks = ["# Automatically generated from Geofeed, DO NOT EDIT", ""]
    blocks.append(build_version_and_master_text(master_cidr, source, master_country_code, existing_create_time))

    for row in csv_content:
        geo = build_geo_row(row, ip_version)
        if not geo:
            continue
        cidr_addresses = address_map.get(geo["cidr"], OrderedDict())
        blocks.append(build_geodata_text(geo, cidr_addresses))

    text = "\n".join(blocks).rstrip() + "\n"
    return text


def write_if_changed(outpath, content):
    old_content = None
    if os.path.exists(outpath):
        with open(outpath, "r", encoding="utf-8", errors="ignore") as f:
            old_content = f.read()

    if old_content == content:
        print(f"unchanged: {outpath}")
        return False

    os.makedirs(os.path.dirname(outpath), exist_ok=True)
    with open(outpath, "w", encoding="utf-8", newline="\n") as f:
        f.write(content)

    if old_content is None:
        print(f"created: {outpath}")
    else:
        print(f"updated: {outpath}")
    return True


geofeeds = finder.find_and_clean_geofeed()
for fname, data in geofeeds.items():
    source = data["source"]
    csv_content = data["filtered_csv"]
    master_cidr = data.get("master_cidr")
    master_country_code = data.get("master_country_code")

    netip = fname.split("_")[0]
    netip = ipaddress.ip_address(netip)

    if netip.version == 4:
        outpath = "../data/ipv4/" + fname + ".toml"
    else:
        outpath = "../data/ipv6/" + fname + ".toml"

    if not master_cidr:
        print(f"{fname} missing master_cidr, skipping")
        continue

    existing_create_time = load_existing_create_time(outpath)
    existing_address_map = load_existing_addresses(outpath)
    content = render_file_content(
        master_cidr,
        source,
        master_country_code,
        csv_content,
        netip.version,
        existing_address_map,
        existing_create_time,
    )
    write_if_changed(outpath, content)
