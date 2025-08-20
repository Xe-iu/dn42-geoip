package main

import "time"

const (
	mmdbURL        = "https://github.com/Xe-iu/dn42-geoip/releases/download/Build/GeoLite2-City-DN42.mmdb"
	mmdbMirrorURL  = "https://gh-proxy.com/" + mmdbURL
	localFilePath  = "./GeoLite2-City-DN42.mmdb"
	updateInterval = 6 * time.Hour
)
