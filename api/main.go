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

	lat, lon := 0.0, 0.0
	if record.Location.Latitude != nil {
		lat = *record.Location.Latitude
	}
	if record.Location.Longitude != nil {
		lon = *record.Location.Longitude
	}

	return gin.H{
		"ip": ipStr,
		"country": gin.H{
			"name":       record.Country.Names,
			"code":       record.Country.ISOCode,
			"geoname_id": record.Country.GeoNameID,
		},
		"registered_country": gin.H{
			"name":       record.RegisteredCountry.Names,
			"code":       record.RegisteredCountry.ISOCode,
			"geoname_id": record.RegisteredCountry.GeoNameID,
		},
		"continent": gin.H{
			"name":       record.Continent.Names,
			"code":       record.Continent.Code,
			"geoname_id": record.Continent.GeoNameID,
		},
		"city": gin.H{
			"name":   record.City.Names,
			"postal": record.Postal.Code,
		},
		"subdivisions": record.Subdivisions,
		"location": gin.H{
			"latitude":        lat,
			"longitude":       lon,
			"accuracy_radius": int(record.Location.AccuracyRadius),
		},
	}
}

func respond(c *gin.Context, result gin.H) {
	ua := c.GetHeader("User-Agent")
	isCurl := strings.Contains(strings.ToLower(ua), "curl")

	outputFormat := "json"

	inputFormat, ok := c.GetQuery("f")
	if (ok && inputFormat == "text") || (!ok && isCurl) {
		outputFormat = "text"
	}

	if outputFormat == "text" {
		if err, ok := result["error"]; ok {
			c.String(http.StatusBadRequest, "Error: %s\n", err)
			return
		}

		loc := result["location"].(gin.H)

		c.String(http.StatusOK,
			`IP                 : %s
Country            : %v (%s)
Registered Country : %v (%s)
Continent          : %v (%s)
City               : %v
Postal Code        : %s
Coordinates        : %.4f, %.4f (±%dkm)
`,
			result["ip"],
			result["country"].(gin.H)["name"],
			result["country"].(gin.H)["code"],
			result["registered_country"].(gin.H)["name"],
			result["registered_country"].(gin.H)["code"],
			result["continent"].(gin.H)["name"],
			result["continent"].(gin.H)["code"],
			result["city"].(gin.H)["name"],
			result["city"].(gin.H)["postal"],
			loc["latitude"].(float64),
			loc["longitude"].(float64),
			loc["accuracy_radius"].(int),
		)
	} else {
		if _, ok := result["error"]; ok {
			c.JSON(http.StatusBadRequest, result)
		} else {
			c.JSON(http.StatusOK, result)
		}
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

	// 根路径：返回客户端 IP 信息
	router.GET("/", func(c *gin.Context) {
		clientIP := c.ClientIP()
		result := queryIP(clientIP)
		respond(c, result)
	})

	// 查询指定 IP
	router.GET("/q", func(c *gin.Context) {
		ipStr := strings.TrimSpace(c.Query("ip"))
		if ipStr == "" {
			respond(c, gin.H{"error": "missing_ip"})
			return
		}
		result := queryIP(ipStr)
		respond(c, result)
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
