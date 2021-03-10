docker login --username $DOCKER_USER \
             --password $DOCKER_PASSWORD 

docker tag anypay anypay/cash-register-flutter:$CIRCLE_BRANCH

docker push anypay/cash-register-flutter:$CIRCLE_BRANCH

