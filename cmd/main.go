package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/rs/zerolog/log"
	"go-lambda/services"
)

var service services.ApiService

func init() {
}
func main() {
	log.Print("Lambda started")
	lambda.Start(service.HandleRequest)
}
