import os
import re
import csv
import requests
import ipaddress

dirs = ["registry/data/inetnum", "registry/data/inet6num"]
pattern_geofeed = re.compile(r'^\s*remarks:\s*geofeed\s+(\S+)', re.IGNORECASE)
pattern_cidr = re.compile(r'^\s*cidr:\s*(\S+)', re.IGNORECASE)
pattern_source = re.compile(r'^\s*source:\s*(\S+)', re.IGNORECASE)
pattern_country = re.compile(r'^\s*country:\s*(\S+)', re.IGNORECASE)
ca_bundle_path = "ca-bundle.crt"

def read_file_cidrs(file_path):
    """读取文件中所有cidr"""
    cidrs = []
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                match = pattern_cidr.match(line)
                if match:
                    cidrs.append(match.group(1))
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
    return cidrs

def read_file_source(file_path):
    """读取文件中第一个 source"""
    source = ""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                match = pattern_source.match(line)
                if match:
                    source = match.group(1)
                    break
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
    return source

def read_file_country(file_path):
    """读取文件中第一个 country"""
    country = ""
    try:
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                match = pattern_country.match(line)
                if match:
                    country = match.group(1)
                    break
    except Exception as e:
        print(f"无法读取文件 {file_path}: {e}")
    return country

def download_geofeed_csv(url):
    """下载 geofeed csv，并返回行列表"""
    try:
        r = requests.get(url, verify=ca_bundle_path, timeout=10)
        r.raise_for_status()
        content = r.text.splitlines()
        return content
    except Exception as e:
        print(f"下载失败 {url}: {e}")
        return []

def filter_geofeed_csv(csv_lines, cidrs):
    """根据 cidr 筛选 geofeed csv"""
    allowed_networks = [ipaddress.ip_network(cidr) for cidr in cidrs]
    filtered = []
    for row in csv.reader(csv_lines):
        if not row or row[0].startswith("#"):
            continue
        ip = row[0].split("/")[0]
        try:
            ip_obj = ipaddress.ip_address(ip)
            if any(ip_obj in net for net in allowed_networks):
                filtered.append(row)
        except ValueError:
            continue
    return filtered

def find_and_clean_geofeed():
    """
    返回格式:
    {
        filename: {
            "source": "...",
            "filtered_csv": [...],
            "master_cidr": "x.x.x.x/y",
            "master_country_code": "CN"
        }
    }
    """
    result = {}
    for dir_path in dirs:
        for root, _, files in os.walk(dir_path):
            for file in files:
                file_path = os.path.join(root, file)
                cidrs = read_file_cidrs(file_path)
                source = read_file_source(file_path)
                country_code = read_file_country(file_path)
                if not cidrs:
                    continue
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        for line in f:
                            match = pattern_geofeed.match(line)
                            if match:
                                url = match.group(1)
                                print(f"匹配到: {file} {url}")
                                csv_lines = download_geofeed_csv(url)
                                filtered_csv = filter_geofeed_csv(csv_lines, cidrs)
                                master_cidr = cidrs[0]  # 主网段为第一个 cidr
                                result[file] = {
                                    "source": source,
                                    "filtered_csv": filtered_csv,
                                    "master_cidr": master_cidr,
                                    "master_country_code": country_code
                                }
                except Exception as e:
                    print(f"无法读取文件 {file_path}: {e}")
    return result
