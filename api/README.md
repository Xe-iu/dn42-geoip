# API

该目录下包含一个基于 Go 和 Gin 的轻量 IP 查询服务，使用 DN42-GeoIP 数据库提供 IP 的地理位置查询，包括国家、城市、行政区、经纬度等信息。

## 特性

- 自动下载并加载 MMDB 数据库文件
- 支持实时更新 MMDB 数据库而不中断服务
- 提供 HTTP API 查询 IP 信息
- 响应数据包含国家、注册国家、城市、行政区和地理位置等详细信息
- 基于 Gin 框架，轻量、高性能

## 安装与运行

您也可以使用 Docker 来运行该服务，具体请参考目录下的 `docker-compose.yml` 文件。

### 克隆仓库

```bash
git clone https://github.com/Xe-iu/dn42-geoip.git
cd dn42-geoip/api
```

### 安装依赖

```bash
go mod download
```

### 编译

```bash
go build -o api .
```

### 运行

```
Usage of ./api:
  -host string
        Server host (default "0.0.0.0")
  -mmdb-source string
        MMDB source: github or mirror (default "github")
  -port int
        Server port (default 8080)
```

## API 使用说明

### 查询当前 IP 信息

```
GET /
```

**请求示例**

```bash
curl http://127.0.0.1:8080/
```

**响应示例**

```json
{
  "city": {
    "name": {
      "de": "Shanghai",
      "en": "Shanghai",
      "es": "Shanghai",
      "fr": "Shanghai",
      "ja": "上海",
      "pt-BR": "Xangai",
      "ru": "Шанхай",
      "zh-CN": "上海"
    },
    "postal": ""
  },
  "continent": {
    "code": "AS",
    "geoname_id": 6255147,
    "name": {
      "de": "Asien",
      "en": "Asia",
      "es": "Asia",
      "fr": "Asie",
      "ja": "アジア",
      "pt-BR": "Ásia",
      "ru": "Азия",
      "zh-CN": "亚洲"
    }
  },
  "country": {
    "code": "CN",
    "geoname_id": 1796236,
    "name": {
      "de": "China",
      "en": "China",
      "es": "China",
      "fr": "Chine",
      "ja": "中国",
      "pt-BR": "China",
      "ru": "Китай",
      "zh-CN": "中国"
    }
  },
  "ip": "172.20.54.57",
  "location": {
    "accuracy_radius": 200,
    "latitude": 31.22222,
    "longitude": 121.45806
  },
  "registered_country": {
    "code": "CN",
    "geoname_id": 1814991,
    "name": {
      "de": "China",
      "en": "China",
      "es": "China",
      "fr": "Chine",
      "ja": "中国",
      "pt-BR": "China",
      "ru": "Китай",
      "zh-CN": "中国"
    }
  },
  "subdivisions": [
    {
      "names": {
        "de": "Shanghai",
        "en": "Shanghai",
        "fr": "Municipalité de Shanghai",
        "pt-BR": "Xangai",
        "zh-CN": "上海市"
      }
    }
  ]
}
```

### 查询指定 IP 信息

```
GET /q?ip=<IP_ADDRESS>
```

**请求示例**

```bash
curl "http://127.0.0.1:8080/q?ip=172.20.54.57"
```

**响应示例**

与 `/` 相同，只是 `ip` 字段为指定的 IP。

### 错误响应

* 缺少 IP 参数：

```json
{
  "error": "missing_ip"
}
```

* IP 无效：

```json
{
  "error": "invalid_ip"
}
```

* 数据库未准备好：

```json
{
  "error": "db_not_ready"
}
```

* 查询内部错误：

```json
{
  "error": "internal_error"
}
```
