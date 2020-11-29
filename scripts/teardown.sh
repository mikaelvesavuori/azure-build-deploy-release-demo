#!/usr/bin/env bash

export RG_NAME="AzureReleaseDemo"

echo 'Deleting your Azure resource group and everything inside of it. You will not need to wait for this command to finish; it will continue in the background.'

az group delete \
  --name $RG_NAME \
  --no-wait \
  --yes