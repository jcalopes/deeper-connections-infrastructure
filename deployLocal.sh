#!/bin/bash
# Replace the image tag with the desired tag to install a new container version.
# To deploy and run locally under infrastructure folder execute the following commands

#To check the generated yaml without install any resources run the command below:
# helm install routes-service .\routes-service\ --dry-run --debug -f ./routes-service/dev-dev-dev-dev-values.yaml
# helm install accounts-service .\accounts-service\ --dry-run --debug -f ./accounts-service/dev-dev-dev-dev-values.yaml
# helm install web-app .\web-app\ --dry-run --debug -f ./web-app/dev-dev-dev-values.yaml

# You need to add or update the following line below with the hosts used on the project: C:\Windows\System32\drivers\etc\hosts
# 127.0.0.1 web.trashtalker.internal be.trashtalker.internal

kubectl config use-context docker-desktop
kubectl create namespace trash-talker

helm install postgres -f ./k8s-3party-apps/postgres-values.yaml oci://registry-1.docker.io/bitnamicharts/postgresql --namespace trash-talker
#helm install keycloak -f ./k8s-3party-apps/keycloak-values.yaml oci://registry-1.docker.io/bitnamicharts/keycloak --namespace trash-talker
kubectl apply -k ./k8s-3party-apps --namespace trash-talker
kubectl apply -k ./k8s-3party-apps/rabbitmq --namespace trash-talker
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.5.1/deploy/static/provider/cloud/deploy.yaml --context docker-desktop

kubectl apply -k ./secrets --namespace trash-talker
helm upgrade -i accounts-service ./accounts-service --set image.tag=0.0.31 -f ./accounts-service/dev-values.yaml
helm upgrade -i routes-service ./routes-service --set image.tag=0.0.35 -f ./routes-service/dev-values.yaml
helm upgrade -i containers-service ./containers-service --set image.tag=0.0.24 -f ./containers-service/dev-values.yaml
helm upgrade -i sensors-mock ./sensors-mock --set image.tag=0.0.13 -f ./sensors-mock/dev-values.yaml
helm upgrade -i web-app ./web-app --set image.tag=0.0.4 -f ./web-app/dev-values.yaml
