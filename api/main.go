package main

import (
	"flag"
	"fmt"
	"net/http"
	"net/netip"
	"os"
	"os/signal"
	"strings"
	"syscall"

	"github.com/gin-gonic/gin"
)

var (
	flagHost       string
	flagPort       int
	flagMmdbSource string
)

func init() {
	// 命令行参数
	flag.StringVar(&flagHost, "host", "0.0.0.0", "Server host")
	flag.IntVar(&flagPort, "port", 8080, "Server port")
	flag.StringVar(&flagMmdbSource, "mmdb-source", "github", "MMDB source: github or mirror")
	flag.Parse()
}

func queryIP(ipStr string) gin.H {
	reader := getReader()
	if reader == nil {
		return gin.H{"error": "db_not_ready"}
	}

	ipaddr, err := netip.ParseAddr(ipStr)
	if err != nil {
		return gin.H{"error": "invalid_ip"}
	}

	record, err := reader.City(ipaddr)
	if err != nil || record == nil {
		return gin.H{"error": "internal_error"}
	}

	return gin.H{
		"ip": ipStr,
		"country_info": gin.H{
			"info": gin.H{
				"name":       record.Country.Names,
				"code":       record.Country.ISOCode,
				"geoname_id": record.Country.GeoNameID,
			},
			"registered": gin.H{
				"name":       record.RegisteredCountry.Names,
				"code":       record.RegisteredCountry.ISOCode,
				"geoname_id": record.RegisteredCountry.GeoNameID,
			},
		},
		"continent": gin.H{
			"name":       record.Continent.Names,
			"code":       record.Continent.Code,
			"geoname_id": record.Continent.GeoNameID,
		},
		"city_info": gin.H{
			"name":   record.City.Names,
			"postal": record.Postal.Code,
		},
		"subdivisions": record.Subdivisions,
		"location": gin.H{
			"latitude":        record.Location.Latitude,
			"longitude":       record.Location.Longitude,
			"accuracy_radius": record.Location.AccuracyRadius,
		},
	}
}

func main() {
	// 捕获退出信号
	stopCh := make(chan struct{})
	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, syscall.SIGINT, syscall.SIGTERM)

	sourceUrl := mmdbURL
	if flagMmdbSource == "mirror" {
		sourceUrl = mmdbMirrorURL
	}

	if _, err := os.Stat(localFilePath); os.IsNotExist(err) {
		fmt.Printf("下载 MMDB 文件: %s\n", sourceUrl)
		if err := downloadMMDB(sourceUrl, localFilePath); err != nil {
			panic(err)
		}
	}

	r, err := loadMMDB(localFilePath)
	if err != nil {
		panic(err)
	}
	currentReader.Store(r)

	// 后台更新
	go updateLoop(sourceUrl, stopCh)

	// Gin 服务器
	gin.SetMode(gin.ReleaseMode)
	router := gin.Default()
	router.Use(func(c *gin.Context) {
		c.Header("X-Powered-By", "https://github.com/Xe-iu/dn42-geoip")
		c.Next()
	})

	router.GET("/", func(c *gin.Context) {
		clientIP := c.ClientIP()
		result := queryIP(clientIP)
		if _, ok := result["error"]; ok {
			c.JSON(http.StatusBadRequest, result)
		} else {
			c.JSON(http.StatusOK, result)
		}
	})

	router.GET("/q", func(c *gin.Context) {
		ipStr := c.Query("ip")
		ipStr = strings.TrimSpace(ipStr)
		if ipStr == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "missing_ip"})
			return
		}
		result := queryIP(ipStr)
		if _, ok := result["error"]; ok {
			c.JSON(http.StatusBadRequest, result)
		} else {
			c.JSON(http.StatusOK, result)
		}
	})

	serverAddr := fmt.Sprintf("%s:%d", flagHost, flagPort)
	fmt.Printf("启动服务器: http://%s\n", serverAddr)
	go func() {
		if err := router.Run(serverAddr); err != nil {
			panic(err)
		}
	}()

	// 等待退出
	<-sigCh
	fmt.Println("收到退出信号，关闭 reader 并退出")
	close(stopCh)

	finalReader := getReader()
	if finalReader != nil {
		finalReader.Close()
	}
}
