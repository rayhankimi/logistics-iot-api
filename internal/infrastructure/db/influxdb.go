package db

import (
	"fmt"
	influxdb2 "github.com/influxdata/influxdb-client-go/v2"
	"log"
	"os"
)

func InfluxDBInit() {
	token := os.Getenv("INFLUXDB_TOKEN")
	if token == "" {
		log.Fatal("[DB]    - InfluxDB Token not set")
	}
	url := fmt.Sprintf("https://localhost:%s", os.Getenv("INFLUXDB_TOKEN"))
	client := influxdb2.NewClientWithOptions(url, token, influxdb2.DefaultOptions())

	defer client.Close()
}
