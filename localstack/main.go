package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/rs/zerolog/log"
	"go-lambda/services"
	"os"
)

var service services.ApiService

func init() {
	host := os.Getenv("LOCALSTACK_HOSTNAME")
	region := os.Getenv("AWS_DEFAULT_REGION")
	log.Printf("GOT LOCALSTACK HOST NAME: %s", host)
	endpoint := fmt.Sprintf("http://%s:4566", host)
	sess := session.Must(session.NewSession(&aws.Config{
		Credentials: credentials.NewStaticCredentials("localstack", "localstack", "localstack"),
		Region:      aws.String(region),
		Endpoint:    aws.String(endpoint),
	}))

	service = *services.NewApiService(sess)
}
func main() {
	log.Print("Lambda started")
	lambda.Start(service.HandleRequest)
}
