export STORAGE_ACCOUNT="builddeployrelease${RANDOM}"
export RG="AzureReleaseDemo"
export LOCATION="westeurope"

export APP_NAME="azurebuilddeployrelease"
export OS="Windows"
export RUNTIME="node"
export SECONDARY_SLOT="staging"

export API_ID="DemoApi"
export API_DISPLAY_NAME="Demo API"
export API_SERVICE_NAME="builddeployrelease${RANDOM}"
export API_DESC="API for release/deployment management demo"
export API_PLAN="Consumption" # One of: Basic, Consumption, Developer, Premium, Standard
export PUBLISHER_EMAIL="youremail@someexamplehere.net"
export PUBLISHER_NAME="YourName"