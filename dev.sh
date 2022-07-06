function deploy() {
  environment=$2
    docker inspect --format="{{.Id}}" localstack || {
        echo 'localstack not running, make sure your containers are running by using start.'
        exit 1
    }
    echo "Removing state files"
    wd=./terraform/environment/$environment
    rm -rf $wd/.terraform/
    rm -f $wd/.terraform.lock.hcl
    rm -f $wd/terraform.tfstate
    rm -f $wd/terraform.tfstate.backup
    echo "Creating symlink for environment files"
    cp ./terraform/resources/* ./terraform/environments/dev
    bucket=$(aws ssm get-parameter --name "go-lambda-bucket" | jq '.Parameter.Value' | xargs)
    echo "Bucket = $bucket"
    awslocal ssm put-parameter --name "go-lambda-bucket" --value $bucket
    awslocal s3 mb "s3://$bucket"
    terraform -chdir $wd init 
    terraform -chdir $wd apply 
}
function start() {
  echo "Starting containers..."
  docker-compose up -d
}

function stop() {
  echo "Stopping containers...."
  docker-compose down
}

function cleanup() {
    echo "Removing state files"
    environment=$2
    wd=./terraform/environment/$environment
    rm -rf $wd/.terraform/
    rm -f $wd/.terraform.lock.hcl
    rm -f $wd/terraform.tfstate
    rm -f $wd/terraform.tfstate.backup
}

case "$1" in
start) start exit 0 ;;
stop) stop exit 1 ;;
deploy) deploy exit 2 ;;
cleanup) cleanup exit 4 ;;
*) message exit 5 ;;
esac
