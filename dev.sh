function deploy_development() {
    docker inspect --format="{{.Id}}" localstack_main || {
        echo 'localstack not running, make sure your containers are running by using start.'
       // start
       // sleep 10
    }
    echo "Removing state files"
    wd="$PWD/terraform/environments/dev"
    rm -rf $wd/.terraform/
    rm -f $wd/.terraform.lock.hcl
    rm -f $wd/terraform.tfstate
    rm -f $wd/terraform.tfstate.backup
    ln -s $PWD/terraform/resources/* $wd
    export AWS_DEFAULT_REGION=us-east-2
    bucket=$(aws ssm get-parameter --name "go-lambda-bucket" | jq '.Parameter.Value' | xargs)
    echo "Bucket = $bucket"
    awslocal ssm put-parameter --name "go-lambda-bucket" --value $bucket
    awslocal s3 mb "s3://$bucket"
    terraform -chdir=$wd init 
    terraform -chdir=$wd apply --auto-approve  
}
function update_function_development() {
  GOOS=linux go build -o ./bin/main ./cmd/main.go
  wd="$PWD/terraform/environments/dev"
  terraform -chdir=$wd apply --auto-approve
}
function update_function_production() {
  GOOS=linux go build -o ./bin/main ./cmd/main.go
  wd="$PWD/terraform/environments/production"
  terraform -chdir=$wd apply --auto-approve
}
function tail_logs_production(){
  wd="$PWD/terraform/environments/production"
  LAMBDA_NAME=$(terraform -chdir=$wd output  --json | jq '.lambda_name.value' | xargs)
  export AWS_DEFAULT_REGION=us-east-1
  echo $LAMBDA_NAME
  aws logs tail "/aws/lambda/$LAMBDA_NAME" 
}
function tail_logs_development(){
  wd="$PWD/terraform/environments/dev"
  LAMBDA_NAME=$(terraform -chdir=$wd output  --json | jq '.lambda_name.value' | xargs)
  export AWS_DEFAULT_REGION=us-east-2
  echo $LAMBDA_NAME
  awslocal logs tail "/aws/lambda/$LAMBDA_NAME" 
}
function deploy_production() {
    docker inspect --format="{{.Id}}" localstack_main || {
        echo 'localstack not running, make sure your containers are running by using start.'
        exit 1
    }
    wd="$PWD/terraform/environments/production"
    ln -s $PWD/terraform/resources/* $wd
    export AWS_DEFAULT_REGION=us-east-1
    terraform -chdir=$wd init 
    terraform -chdir=$wd apply --auto-approve
}
function destroy_production() {
  wd="$PWD/terraform/environments/production"
  terraform -chdir=$wd destroy --auto-approve 
}
function destroy_development() {
    echo "Removing state files"
    wd="$PWD/terraform/environments/dev"
    rm -rf $wd/.terraform/
    rm -f $wd/.terraform.lock.hcl
    rm -f $wd/terraform.tfstate
    rm -f $wd/terraform.tfstate.backup
    stop
}
function start() {
  echo "Starting localstack..."
  export AWS_DEFAULT_REGION=us-east-2
  docker-compose up -d
}

function stop() {
  docker-compose down
}

function message() {
  echo "\x1B[33mDev Server Commands\x1B[0m"
  echo "\x1B[4mUsage:\x1B[24m\n  $0 \x1B[2m{|start|stop|deploy|cleanup}\x1B[0m\n"

  echo "\x1B[4mAvailable Commands\x1B[0m"
  echo "   start-localstack: \x1B[2mStart Localstack\x1B[22m"
  echo "   stop-localstack: \x1B[2mStop Localstack\x1B[22m"
  echo "   deploy-development: \x1B[2mDeploy development environment to localstack\x1B[22m"
  echo "   deploy-production: \x1B[2mDeploy resources to AWS\x1B[22m"
  echo "   destroy-development: \x1B[2mDestroy Localstack resources\x1B[22m"
  echo "   destroy-production: \x1B[2mDestroy AWS resources\x1B[22m"
  echo "   update-function-development: \x1B[2mUpdate the function in Localstack\x1B[22m"
  echo "   update-function-production: \x1B[2mUpdate the function in AWS\x1B[22m"
  echo "   tail-logs-development: \x1B[2mGet logs for function in Localstack\x1B[22m"
  echo "   tail-logs-production: \x1B[2mGet logs for function in AWS\x1B[22m"
}
case "$1" in
start-localstack) start ;;
stop-localstack) stop ;;
deploy-development) deploy_development ;;
deploy-production) deploy_production ;;
destroy-development) destroy_development ;;
destroy-production) destroy_production ;;
tail-logs-production) tail_logs_production ;;
tail-logs-development) tail_logs_development ;;
update-function-development) update_function_development ;;
update-function-production) update_function_production;;
*) message ;;
esac
