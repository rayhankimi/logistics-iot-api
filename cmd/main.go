package main

import (
	"fmt"
	"logistics/internal/infrastructure/config"
	"logistics/internal/infrastructure/db"
)

func init() {
	config.LoadEnv()
	db.PostgresInit()
}

func main() {
	mqtt := config.InitializeMQTT()
	defer mqtt.Client.Disconnect(250)

	fmt.Println("Hello World")
	select {}
}
