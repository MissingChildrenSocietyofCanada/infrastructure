# Missing Children Society of Canada

## Description
All required Azure infrastructure in the form of ARM Templates.

## Quick start
1. Clone
2. Fill Out:
- [mcsc-serviceBus.parameters.json](https://github.com/Missing-Children-Society-Canada/infrastructure/blob/master/mcsc-serviceBus.parameters.json)
- [TwitterPull-LogicApp.parameters.json](https://github.com/Missing-Children-Society-Canada/infrastructure/blob/master/TwitterPull-LogicApp.parameters.json)
- [mcsc-webhook.parameters.json](https://github.com/Missing-Children-Society-Canada/infrastructure/blob/master/mcsc-webhook.parameters.json)
- [mscs-cf-functions-v2.parameters.json](https://github.com/Missing-Children-Society-Canada/infrastructure/blob/master/mscs-cf-functions-v2.parameters.json)
3. If executing the Deploy-MCSC-Architecture script, you will need to log in via two different mechanisms, as the script uses both Azure Powershell and Azure CLI commands
  3.1 Open Azure CLI
  3.2 Login-AzureRMAccount
  3.3 az login
  3.4 Powershell -File Deploy-MCSC-Architecture.ps1
