###################
#      DevOps     #
###################

# Setup Azure DevOps
az extension add --name azure-devops

# You could probably script this but it's just a bit wonky when I've put my hands to it
#az devops project create --name $APP_NAME --detect
#az repos create --name $APP_NAME --detect --open

az pipelines create --name 'Master' --description 'Pipeline for master branch' --yml-path pipelines/master.yml
az pipelines create --name 'Feature' --description 'Pipeline for feature branch' --yml-path pipelines/feature.yml
az pipelines create --name 'Release' --description 'Pipeline for releases' --yml-path pipelines/release.yml