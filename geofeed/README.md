# Geofeed

该目录下包含通过 Registry 中登记的 Geofeed 数据填充 geoip 生成数据的脚本。

使用前，需要先下载 [allCountries.zip](https://download.geonames.org/export/dump/allCountries.zip) 并解压到当前文件夹中，同时将 DN42 Registry clone 至 registry 目录下。

然后执行`python3 update.py`即可同步数据。
