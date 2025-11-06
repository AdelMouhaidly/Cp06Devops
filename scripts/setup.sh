#!/bin/bash

echo "Informe seu RM (rmXXXXX):"
read RM

ACR_NAME="2tds251cp6${RM}"
APP_SERVICE_PLAN="plan-2tds251cp6${RM}"
DBNAME="transactions"
LOCATION="brazilsouth"
PASSWORD="Fiap@2tdsvms"
RG="rg-cp6-2tds"
SERVER_NAME="postgres-cp6-${RM}"
USERNAME="admpostgres"
WEBAPP_NAME="2tds251cp6${RM}"
IMAGE_NAME="transaction"

az group create --name $RG --location $LOCATION

az acr create --resource-group $RG --name $ACR_NAME --sku Basic --admin-enabled

ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query "username" -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

# Create PostgreSQL Flexible Server
az postgres flexible-server create \
  --resource-group $RG \
  --name $SERVER_NAME \
  --location $LOCATION \
  --admin-user $USERNAME \
  --admin-password $PASSWORD \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --version 15 \
  --storage-size 32 \
  --public-access 0.0.0.0-255.255.255.255

# Create database
az postgres flexible-server db create \
  --resource-group $RG \
  --server-name $SERVER_NAME \
  --database-name $DBNAME

az appservice plan create \
  --name $APP_SERVICE_PLAN \
  --resource-group $RG \
  --location $LOCATION \
  --sku F1 \
  --is-linux

az webapp create \
  --name $WEBAPP_NAME \
  --resource-group $RG \
  --plan $APP_SERVICE_PLAN \
  --runtime "JAVA:21-java21"

az webapp config container set \
    --name $WEBAPP_NAME \
    --resource-group $RG \
    --container-image-name ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest \
    --container-registry-url https://${ACR_NAME}.azurecr.io \
    --container-registry-user $ACR_USERNAME \
    --container-registry-password $ACR_PASSWORD

az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RG" \
  --settings \
    WEBSITES_PORT=8080 \
    SPRING_DATASOURCE_URL="jdbc:postgresql://${SERVER_NAME}.postgres.database.azure.com:5432/${DBNAME}?sslmode=require" \
    SPRING_DATASOURCE_USERNAME="${USERNAME}" \
    SPRING_DATASOURCE_PASSWORD="$PASSWORD"
