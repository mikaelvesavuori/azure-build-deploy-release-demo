export STORAGE_ACCOUNT="builddeployrelease${RANDOM}"
export RG="AzureReleaseDemo"
export LOCATION="westeurope"
export APP_NAME="azure-build-deploy-release"
export OS="Windows"
export RUNTIME="node"
export SECONDARY_SLOT="staging"

export PLAN_NAME="AzureReleaseDemoPlan"
export PLAN="Consumption" #FREE

export API_ID="DemoApi"
export API_SERVICE_NAME="DemoApiManagement${RANDOM}"
export API_DISPLAY_NAME="Demo API"
export API_DESC="API for release/deployment management demo"
export API_PLAN="Consumption"
export PUBLISHER_EMAIL="youremail@someexamplehere.net"
export PUBLISHER_NAME="YourName"
