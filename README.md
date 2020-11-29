# Demo: Azure modern build-deploy-release process, using Functions and DevOps

This repo demonstrates how to set up a DevOps-oriented CI/CD pipeline for a modern build-deploy-release flow.

It will help you set up Azure DevOps to contain your source code, build your application, deploy it to a staging environment (a staging Deployment slot), and release an Azure Functions app to your production environment. You also get an API Management instance that can "front" your demo Azure Functions application.

The methodology promoted here is:

- [CI/CD](https://www.redhat.com/en/topics/devops/what-is-ci-cd) (continuous integration and deployment), meaning code is pushed "eagerly" and often, and that it gets deployed to a _real_ environment
- [Trunk-based development](https://trunkbaseddevelopment.com), meaning that you only push to master (ideally with pull requests and code review)
- [DevOps](https://azure.microsoft.com/en-us/overview/what-is-devops/), meaning the team owns everything involved in an app (infra, application code, monitoring...)
- [Testing in production](https://copyconstruct.medium.com/testing-in-production-the-safe-way-18ca102d0ef1), meaning that you can gradually shift a bit of traffic to new code, monitor it for health/errors and decide with data if it's time to push it to everyone

Developers would push to the `master` branch, get the code tested, built and deployed in their staging slot. Then, by pushing a Git tag on the `master` branch, the code in the staging slot is swapped over to the production slot, without downtime.

While long-lived feature branches are advised against in trunk-based development, I've included a `feature` pipeline if your team would have the need of a separate deployment (separate plan, app, etc.) of a service, which should _not_ be part of the primary app. This could be useful for very specific cases like keeping a short-lived UAT copy.

Lastly, this setup improves a bit on Serverless Framework (which is used here) and it's poor default, by ticking a range of security best practices boxes for the required Azure infrastructure resources (storage, function traffic...).

The tech is listed a bit more below:

**Stack**

- [Serverless Framework](https://www.serverless.com)
- [Azure Functions](https://azure.microsoft.com/en-us/services/functions/) + [Azure Storage](https://azure.microsoft.com/en-us/services/storage/) for storing the function + [Azure API Management](https://azure.microsoft.com/en-us/services/api-management/)
- [Webpack](https://webpack.js.org) for bundling and optimizing
- [Babel](https://babeljs.io) for transpiling files
- [Typescript](https://www.typescriptlang.org) so we can write better code

## Prerequisites

- Azure account
- Logged in to Azure through environment
- High enough credentials to create required resources
- **Recommended**: Serverless Framework installed on your system
- Perform some manual steps as listed below

Also, before deploying anything, you should run the production app initialization script. The script will set up the required resources (instead of Serverless Framework), since we want to 1) secure the app better and manually configure all the things, 2) since we want to use deployment slots, prior to using them we need to set them up, which is easier when we can configure known names etc. It will set up required infrastructure, but not anything on Azure DevOps—that is a manual step here.

### Manual steps

Please read the below before actually starting to work:

1. **Create an Azure DevOps organization, project, and Git repository**. This step could be automated but I find this to be somewhat unintuitive; manual work is easy and fast enough. Do this by searching for `devops` in the Azure search. Do the necessary steps.
2. **You will need a _service connection_ to deploy later**. Go to `Project settings` > `Service connections` > `Create service connection` > Choose `Azure Resource Manager` > Choose `Service principal (automatic)` > Set subscription to whatever your sub is; resource group to `AzureReleaseDemo`; service connection name to `service-connection-arm-pipeline`, and save (see [https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml) for more information)
3. Note: You will need to click `Authorize resources` in each of the pipelines as you attempt to deploy.
4. Set/export the variables in `scripts/vars.sh` into your environment
5. Run `sh scripts/init.sh` or `npm run init` to create Azure infrastructure
6. Run `sh scripts/devops-pipelines.sh` to create the Azure DevOps pipelines
7. **Push your Git repo to Azure DevOps**. Follow instructions inside Azure DevOps for how to do this.
8. **Once the application has been deployed the first time, you can import the Function App as an API for API Management**. Refer to [https://docs.microsoft.com/en-us/azure/api-management/import-function-app-as-api](https://docs.microsoft.com/en-us/azure/api-management/import-function-app-as-api) on how to do this. This step is unfortunately (AFAIK) not possible to automate with Bash or Powershell at the time of writing. If you skip this step, nothing bad will happen, other than that you will have an un-used API instance. You can still (with the configuration I provide) anonymously (openly) call the function itself. I'd still urge you to put the API in front of the function.

With the above you should now have gone full circle. Congratulations!

### Optional (non-automated steps)

#### Monitoring

You should consider activating [Application Insights](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) and [Azure Monitor](https://docs.microsoft.com/en-us/azure/azure-monitor/overview) for the Function app, so you can be on top of any activities as they happen, not when your customers complain! :)

I'm actually not really sure how these things can be done in a good way with either ARM or the ´az´ CLI. Anyway these things are relatively smooth to set up, and you may want to customize them to your needs anyway.

#### Feature toggles

To actually be able to do "testing in production", consider using feature toggles. Since you are already using Azure, take a look at [Azure App Configuration](https://docs.microsoft.com/en-us/azure/azure-app-configuration/overview). I made a [demo for Azure App Configuration](https://github.com/mikaelvesavuori/azure-appconfig-toggles-node-demo) with a more "realistic" project setup, and even made a library, [appconfig-toggles](https://github.com/mikaelvesavuori/appconfig-toggles), that will help you have a _really easy_ time using Azure App Configuration in a Node project.

## Install

Install dependencies with `npm install` or `yarn add`.

## Log in to Azure

1. `az account clear`
2. `az login`

Then set credentials as per instructions at [https://github.com/serverless/serverless-azure-functions#advanced-authentication](https://github.com/serverless/serverless-azure-functions#advanced-authentication).

## Development

Run `sls offline`. After a bit of building files and doing its magic, you get a prompt looking like:

```
Http Functions:

demoFunction: [GET] http://localhost:7071/demoFunction
```

Hit that URL and you're ready! It doesn't do auto-reloads though.

## How to handle configuration?

While you can use Azure DevOps to "build-in" your environment variables, _you should remember that the application is only built once, in the staging environment_. It is not re-built for the production environment, just swapped from the staging to the production slot. While it may sound counter-intuitive, this is _better_ (same artifact) and you should be able to fully trust the swapped environment since the exact same code has been out and used. It also makes it harder to do dumb things like building in hard-coded stage-based variables.

To do stage-specific configuration, you should use the App Settings for your Function App instead.

**NOTE!**
_Your Node version will need to be 12_ (or whatever version is used on Azure). One way of handling multiple Node versions is with [`nvm`](https://github.com/nvm-sh/nvm). If you are set on using it, these instructions should get you up and ready for development:

1. `nvm install 12`, to install Node 12
2. `nvm use 12`, to use Node 12
3. When you are done, run `nvm unload` but this will also eject the environment variables so `nvm` will be an unknown command from that point on (just run the commands again from `~/.zshrc` or where ever those got put in the first place)

## Remove

Run `npm run teardown` or `yarn run teardown`. This command does the following:

- Runs `sls remove` to remove the function stack.
- Runs `sh ./scripts/teardown.sh` to remove the storage for fonts and documents.
