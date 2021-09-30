# Define the variables
RESOURCE_SUFFIX=$RANDOM
RESOURCE_GROUP=GitpodOpenVSCode$RESOURCE_SUFFIX
LOCATION=australiaeast
SHARE_NAME=openvscode
STORAGE_ACCOUNT_NAME=openvscode$RESOURCE_SUFFIX
DNS_LABEL=gitpod-openvscode-$RESOURCE_SUFFIX
CONTAINER_NAME=$DNS_LABEL

# Create the resource group
az group create \
  --location $LOCATION \
  --name $RESOURCE_GROUP

# Create the storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT_NAME \
  --location $LOCATION \
  --sku Standard_LRS

# Create the file share
az storage share create \
  --name $SHARE_NAME \
  --account-name $STORAGE_ACCOUNT_NAME

# Get the storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)

# Create the container
az container create \
  --resource-group $RESOURCE_GROUP \
  --name $CONTAINER_NAME \
  --image gitpod/openvscode-server \
  --dns-name-label $DNS_LABEL \
  --ports 3000 \
  --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name $SHARE_NAME \
  --azure-file-volume-mount-path /home/workspace

# Get the URI to access the application
ACI_HOST_NAME=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.fqdn --output tsv)
echo http://$ACI_HOST_NAME:3000
echo Done
