package services

import (
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/rs/zerolog/log"
	"net/http"
)

type ApiService struct {
	Session *session.Session
}

func NewApiService(sess *session.Session) *ApiService {
	return &ApiService{
		Session: sess,
	}
}

func (api ApiService) HandleRequest(req events.APIGatewayProxyRequest) (*events.APIGatewayProxyResponse, error) {
	log.Printf("Path is %s", req.Path)

	return &events.APIGatewayProxyResponse{
		StatusCode: http.StatusOK,
		Body:       string("Hello World!!"),
	}, nil
}
