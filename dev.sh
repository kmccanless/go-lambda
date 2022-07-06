function deploy_development() {
    docker inspect --format="{{.Id}}" localstack_main || {
        echo 'localstack not running, make sure your containers are running by using start.'
        start
        sleep 10
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
    terraform -chdir=$wd apply
     
}
function tail_logs_production(){
  wd="$PWD/terraform/environments/production"
  LAMBDA_NAME=$(terraform -chdir=$wd output  --json | jq '.lambda_name.value' | xargs)
  export AWS_DEFAULT_REGION=us-east-1
  echo $LAMBDA_NAME
  aws logs tail "/aws/lambda/$LAMBDA_NAME" 
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
    terraform -chdir=$wd apply 
}
function destroy_production() {
  wd="$PWD/terraform/environments/production"
  terraform -chdir=$wd destroy 
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
  echo "   start: \x1B[2mStart the Docker Containers\x1B[22m"
  echo "   stop: \x1B[2mStop the Docker Containers\x1B[22m"
  echo "   development: \x1B[2mDeploy development environment to localstack\x1B[22m"
  echo "   production: \x1B[2mDeploy resources to AWS\x1B[22m"
}
case "$1" in
start) start ;;
stop) stop ;;
deploy-development) deploy_development ;;
deploy-production) deploy_production ;;
destroy-development) destroy_development ;;
destroy-production) destroy_production ;;
tail_logs_production) tail_logs_production ;;
*) message ;;
esac
