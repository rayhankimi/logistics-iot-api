package config

import (
	"github.com/joho/godotenv"
	"log"
)

func LoadEnv() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("[ENV]    - ERROR loading .env file")
	}
	log.Println("[ENV]    - Loaded .env file")
}
