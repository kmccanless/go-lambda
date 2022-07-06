## Development
`acp <profile>`
docker-compose up
`./dev.sh`

## To Manually Build
GOOS=linux go build -o ./bin/main ./cmd/main.go

## Production
make sure that `terraform apply` is ran in the corresponding environment in go-lambda-infrastructure
cd into terraform/production run `terraform apply`