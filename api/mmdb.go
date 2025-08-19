package main

import (
	"io"
	"net/http"
	"os"
	"sync/atomic"
	"time"

	"github.com/Xe-iu/dn42-geoip/api/geoip2"
)

var currentReader atomic.Value // *geoip2.Reader

func loadMMDB(path string) (*geoip2.Reader, error) {
	return geoip2.Open(path)
}

func downloadMMDB(url, dest string) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	tmpFile := dest + ".tmp"
	out, err := os.Create(tmpFile)
	if err != nil {
		return err
	}
	defer out.Close()

	if _, err := io.Copy(out, resp.Body); err != nil {
		return err
	}

	return os.Rename(tmpFile, dest)
}

func updateLoop(mmdbURL string, stopCh <-chan struct{}) {
	ticker := time.NewTicker(updateInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			println("开始更新 MMDB")

			tmpPath := localFilePath + ".new"
			if err := downloadMMDB(mmdbURL, tmpPath); err != nil {
				println("下载失败:", err.Error())
				continue
			}

			newReader, err := loadMMDB(tmpPath)
			if err != nil {
				println("加载新 MMDB 失败:", err.Error())
				os.Remove(tmpPath) // 删除临时文件
				continue
			}

			oldReader := currentReader.Swap(newReader).(*geoip2.Reader)
			if oldReader != nil {
				oldReader.Close()
			}

			os.Rename(tmpPath, localFilePath)

			println("MMDB 已更新")
		case <-stopCh:
			return
		}
	}
}

func getReader() *geoip2.Reader {
	r := currentReader.Load()
	if r == nil {
		return nil
	}
	return r.(*geoip2.Reader)
}
