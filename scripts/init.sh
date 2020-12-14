#!/usr/bin/env bash

###################
#      Group      #
###################

# Create resource group
az group create --location $LOCATION --name $RG

###################
#     Storage     #
###################

# Create storage account for application
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RG \
  --access-tier Hot \
  --allow-blob-public-access false \
  --sku Standard_LRS \
  --https-only \
  --location $LOCATION \
  --min-tls-version TLS1_2 \
  --kind StorageV2

###################
#    Functions    #
###################

# Create function app
az functionapp create \
  --name $APP_NAME \
  --resource-group $RG \
  --consumption-plan-location $LOCATION \
  --os-type $OS \
  --runtime $RUNTIME \
  --runtime-version 12 \
  --storage-account $STORAGE_ACCOUNT \
  --disable-app-insights false \
  --functions-version 3

# Set function app to only use HTTPS
az functionapp update \
  --name $APP_NAME \
  --resource-group $RG \
  --set httpsOnly=true

# Secure function app
az functionapp config set \
  --name $APP_NAME \
  --resource-group $RG \
  --ftps-state Disabled \
  --http20-enabled true \
  --min-tls-version 1.2 \
  --use-32bit-worker-process false

# Create staging deployment slot for function app
az functionapp deployment slot create \
  --resource-group $RG \
  --name $APP_NAME \
  --slot $SECONDARY_SLOT

###################
# API Management  #
###################

# Create API Management service instance
az apim create \
  --resource-group $RG \
  --location $LOCATION \
  --name $API_SERVICE_NAME \
  --sku-name $API_PLAN \
  --publisher-email $PUBLISHER_EMAIL \
  --publisher-name $PUBLISHER_NAME

# Create API on the service instance
az apim api create \
  --resource-group $RG \
  --api-id $API_ID \
  --display-name $API_DISPLAY_NAME \
  --service-name $API_SERVICE_NAME \
  --path '/' \
  --api-type http \
  --description $API_DESC

# Set function to be run from compiled ZIP package during deployment
az functionapp config appsettings set \
  --resource-group $RG \
  --settings "WEBSITE_RUN_FROM_PACKAGE=1" \
  --name $APP_NAME

az functionapp config appsettings set \
  --resource-group $RG \
  --slot staging \
  --slot-settings "WEBSITE_RUN_FROM_PACKAGE=1" \
  --name $APP_NAME