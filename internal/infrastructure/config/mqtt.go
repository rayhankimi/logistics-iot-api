package config

import (
	"fmt"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"log"
	"os"
	"time"
)

type MQTTConfig struct {
	Host     string
	Port     string
	Username string
	Password string
	Topics   []string
	ClientID string
	Client   mqtt.Client
}

func NewMQTTConfig() *MQTTConfig {
	config := &MQTTConfig{
		Host:     "localhost",
		Port:     os.Getenv("MQTT_PORT"),
		Username: os.Getenv("MQTT_USERNAME"),
		Password: os.Getenv("MQTT_PASSWORD"),
		Topics: []string{
			"logistics/+/speed",
			"logistics/+/drowsiness",
			"logistics/+/accel",
			"logistics/+/gps",
			"logistics/+/temp",
		},
		ClientID: "go-mqtt-client",
	}
	if config.Port == "" || config.Username == "" || config.Password == "" {
		log.Fatal("[MQTT]   - .env for MQTT isn't loaded or given")
	}
	return config
}

func (c *MQTTConfig) GetBrokerURL() string {
	return fmt.Sprintf("tcp://%s:%s", c.Host, c.Port)
}

// Message handlers
var messagePubHandler mqtt.MessageHandler = func(client mqtt.Client, msg mqtt.Message) {
	log.Printf("[MQTT]   - TOPIC: %s with message %s\n", msg.Topic(), msg.Payload())
}

var connectionLostHandler mqtt.ConnectionLostHandler = func(client mqtt.Client, err error) {
	log.Printf("[MQTT]   - CONNECTION LOST: %s\n", err.Error())
}

var onConnectHandler mqtt.OnConnectHandler = func(client mqtt.Client) {
	log.Println("[MQTT]   - Connected to MQTT Broker")
}

func (c *MQTTConfig) Connect() error {
	log.Printf("[MQTT]   - Connecting to %s\n", c.GetBrokerURL())

	opts := mqtt.NewClientOptions()
	opts.AddBroker(c.GetBrokerURL())
	opts.SetClientID(c.ClientID)
	opts.SetUsername(c.Username)
	opts.SetPassword(c.Password)

	opts.SetDefaultPublishHandler(messagePubHandler)
	opts.OnConnect = onConnectHandler
	opts.OnConnectionLost = connectionLostHandler

	opts.SetAutoReconnect(true)
	opts.SetKeepAlive(60 * time.Second)
	opts.SetPingTimeout(1 * time.Second)
	opts.SetConnectTimeout(10 * time.Second)
	opts.SetMaxReconnectInterval(5 * time.Second)
	opts.SetCleanSession(true)

	c.Client = mqtt.NewClient(opts)
	if token := c.Client.Connect(); token.Wait() && token.Error() != nil {
		return fmt.Errorf("[MQTT]   - Error connecting to MQTT Broker: %s", token.Error())
	}
	return nil
}
func (c *MQTTConfig) Subscribe() error {
	if c.Client == nil {
		return fmt.Errorf("[MQTT]   - Client not initialized")
	}

	for _, topic := range c.Topics {
		if token := c.Client.Subscribe(topic, 0, messagePubHandler); token.Wait() && token.Error() != nil {
			log.Printf("[MQTT]   - Error subscribing to topic %s: %s\n", topic, token.Error())
			return token.Error()
		} else {
			log.Printf("[MQTT]   - Subscribed to topic %s\n", topic)
		}
	}
	return nil
}

func InitializeMQTT() *MQTTConfig {
	config := NewMQTTConfig()

	if err := config.Connect(); err != nil {
		log.Fatalf("[MQTT]   - %v", err)
	}

	if err := config.Subscribe(); err != nil {
		log.Fatalf("[MQTT]   - Failed to subscribe %v", err)
	}
	return config
}
