#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************

$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$starttime = get-date

#region Prep & signin
# sign in
Write-Output "Logging in...";

$context = Get-AzureRmContext  -ErrorAction Continue

if ($context -eq $null -or [string]::IsNullOrEmpty($context.Account)) {
    Login-AzureRmAccount | Out-Null
} else {
    Write-Output $context.Account
}
#Login-AzureRmAccount | Out-Null

# Set variables

# select subscription
$subscriptionId = Read-Host -Prompt 'Input your Subscription ID'
$Subscription = Select-AzureRmSubscription -SubscriptionId $SubscriptionId | out-null

# specify environment
$Environment = Read-Host -Prompt 'Input the environment (leave blank for production)'
$PreEnvironment = $Environment

if ($Environment -ne $null -and $Environment -ne '') {
    $Environment = '-' + $Environment
} else {
    $Environment = ''
}

# select Location
$Location = Read-Host -Prompt 'Input the Location for your Resource Group'

# Root GitHub URI
$RootGitHubURI = Read-Host -Prompt 'Input the Root GitHub URI'
$RootGitHubURI = $RootGitHubURI.ToLower()

if ($RootGitHubURI -notmatch '.+?\/$')
{
    $RootGitHubURI += '/'
}

# GitHub Brance
$GitHubBranch = Read-Host -Prompt 'Input the branch for the Root GitHub URI'
$GitHubBranch = $GitHubBranch.ToLower()

# determine defaults
$DefaultResourceGroupName = 'MCSC-HFM' + $Environment
$DefaultDBAccountName = 'mcsc-hfm-db' + $Environment.ToLower()
$DefaultServiceBusName = 'mcsc-hfm-servicebus' + $Environment.ToLower()
$DefaultFunctionName = 'mcsc-hfm-functions' + $Environment.ToLower()
$DefaultWebhookName = 'mcsc-hfm-webhooks' + $Environment.ToLower()
$DefaultWebAppAuthName = 'mcsc-hfm-web-auth' + $Environment.ToLower()
$DefaultWebAppPortalName = 'mcsc-hfm-web-portal' + $Environment.ToLower()
$DefaultTwitterPullLogicAppName = 'mcsc-hfm-twitter-pull' + $Environment.ToLower()
$DefaultTwitterHashtagTrigger = 'HFM' + $PreEnvironment
$DefaultWebsiteNodeDefaultVersion = '4.4.7'
$ResourceGroupName = $null
$DBAccountName = $null
$serviceBusNamespace = $null
$FunctionName = $null
$WebhookName = $null
$WebAppAuthName = $null
$WebAppPortalName = $null
$TwitterPullLogicAppName = $null
$TwitterConsumerKey = $null
$TwitterConsumerSecret = $null
$TwitterAccessTokenKey = $null
$TwitterAccessTokenSecret = $null
$TwitterHashtagTrigger = $null
$FacebookConsumerKey = $null
$FacebookConsumerSecret = $null
$FacebookVerifyToken = $null
$InstagramConsumerKey = $null
$InstagramConsumerSecret = $null
$InstagramVerifyToken = $null
$WebsiteNodeDefaultVersion = $null

Write-Output ''

# Determine if parameter files are being used
$UseParameterFiles = Read-Host -Prompt 'Use parameter files for configuration (root GitHub and environment parameters will be used to locate files under /infrastructure/parameters/)? (Y) Yes, (N) No'

if ($UseParameterFiles -ne 'Y')
{
    Write-Output ''
    Write-Output 'Configure the social media platforms:'

    # Twitter
    $TwitterConsumerKey = Read-Host -Prompt 'Input the Twitter Consumer Key'
    $TwitterConsumerSecret = Read-Host -Prompt 'Input the Twitter Consumer Secret'
    $TwitterAccessTokenKey = Read-Host -Prompt 'Input the Twitter Access Token Key'
    $TwitterAccessTokenSecret = Read-Host -Prompt 'Input the Twitter Access Token Secret'

    # Facebook
    $FacebookConsumerKey = Read-Host -Prompt 'Input the Facebook Consumer Key'
    $FacebookConsumerSecret = Read-Host -Prompt 'Input the Facebook Consumer Secret'
    $FacebookVerifyToken = Read-Host -Prompt 'Input the Facebook Verification Token'
    
    # Instagram
    $InstagramConsumerKey = Read-Host -Prompt 'Input the Instagram Consumer Key'
    $InstagramConsumerSecret = Read-Host -Prompt 'Input the Instagram Consumer Secret'
    $InstagramVerifyToken = Read-Host -Prompt 'Input the Instagram Verification Token'

    Write-Output ''
    $Customize = Read-Host -Prompt 'Do you want to customize the default configuration? (Y) Yes, (N) No'

    if ($Customize -eq 'Y')
    {
    
        # Resource Group
        $ResourceGroupName = Read-Host -Prompt "Input the Resource Group for Solution (default: $DefaultResourceGroupName)"

        # CosmosDB Account Name
        $DBAccountName = Read-Host -Prompt "Input the CosmosDB account name (default: $DefaultDBAccountName)"
        $DBAccountName = $DBAccountName.ToLower()

        # Service Bus Name
        $serviceBusNamespace = Read-Host -Prompt "Input the Service Bus namespace (default: $DefaultServiceBusName)"
        $serviceBusNamespace = $serviceBusNamespace.ToLower()

        # Function Name
        $FunctionName = Read-Host -Prompt "Input the unique Function name (default: $DefaultFunctionName)"
        $FunctionName = $FunctionName.ToLower()

        # Webhook Name
        $WebhookName = Read-Host -Prompt "Input the unique Webhook name (default: $DefaultWebhookName)"
        $WebhookName = $WebhookName.ToLower()

        # Web App Auth Site Name
        $WebAppAuthName = Read-Host -Prompt "Input the unique Web App Auth site name (default: $DefaultWebAppAuthName)"
        $WebAppAuthName = $WebAppAuthName.ToLower()
        
        # Web App Portal Site Name
        $WebAppPortalName = Read-Host -Prompt "Input the unique Web App Portal site name (default: $DefaultWebAppPortalName)"
        $WebAppPortalName = $WebAppPortalName.ToLower()

        # Twitter Pull Logic App Name
        $TwitterPullLogicAppName = Read-Host -Prompt "Input the Twitter Pull Logic App name (default: $DefaultTwitterPullLogicAppName)"
        $TwitterPullLogicAppName = $TwitterPullLogicAppName.ToLower()

        # Twitter Hashtag Trigger
        $TwitterHashtagTrigger = Read-Host -Prompt "Input the Twitter hashtag trigger (default: $DefaultTwitterHashtagTrigger)"
        $TwitterHashtagTrigger = $TwitterHashtagTrigger.ToLower()
        
        # Website Node Default Version
        $WebsiteNodeDefaultVersion = Read-Host -Prompt "Input the website node default version (default: $DefaultWebsiteNodeDefaultVersion)"
        $WebsiteNodeDefaultVersion = $WebsiteNodeDefaultVersion.ToLower()
        
    } 

    if ($ResourceGroupName -eq $null -or $ResourceGroupName -eq '') {
        $ResourceGroupName = $DefaultResourceGroupName
    }

    if ($DBAccountName -eq $null -or $DBAccountName -eq '') {
        $DBAccountName = $DefaultDBAccountName
    }

    if ($serviceBusNamespace -eq $null -or $serviceBusNamespace -eq '') {
        $serviceBusNamespace = $DefaultServiceBusName
    }

    if ($FunctionName -eq $null -or $FunctionName -eq '') {
        $FunctionName = $DefaultFunctionName
    }

    if ($WebhookName -eq $null -or $WebhookName -eq '') {
        $WebhookName = $DefaultWebhookName
    }

    if ($WebAppAuthName -eq $null -or $WebAppAuthName -eq '') {
        $WebAppAuthName = $DefaultWebAppAuthName
    }

    if ($WebAppPortalName -eq $null -or $WebAppPortalName -eq '') {
        $WebAppPortalName = $DefaultWebAppPortalName
    }

    if ($TwitterPullLogicAppName -eq $null -or $TwitterPullLogicAppName -eq '') {
        $TwitterPullLogicAppName = $DefaultTwitterPullLogicAppName
    }

    if ($TwitterHashtagTrigger -eq $null -or $TwitterHashtagTrigger -eq '') {
        $TwitterHashtagTrigger = $DefaultTwitterHashtagTrigger
    }

    if ($WebsiteNodeDefaultVersion -eq $null -or $WebsiteNodeDefaultVersion -eq '') {
        $WebsiteNodeDefaultVersion = $DefaultWebsiteNodeDefaultVersion
    }
}

Write-Output ""
Write-Output "Parameters"
Write-Output "-----------------------------------------------------"
Write-Output "Subscription ID: $subscriptionId"
Write-Output "Environment: $PreEnvironment"
Write-Output "Location: $Location"
Write-Output "Resource Group Name: $ResourceGroupName"
Write-Output "CosmoDB account name: $DBAccountName"
Write-Output "Service Bus namespace: $serviceBusNamespace"
Write-Output "Function name: $FunctionName"
Write-Output "Webhook name: $WebhookName"
Write-Output "Web App Auth site name: $WebAppAuthName"
Write-Output "Web App Portal site name: $WebAppPortalName"
Write-Output "Twitter Pull Logic App name: $TwitterPullLogicAppName"
Write-Output "Twitter hashtag trigger: $TwitterHashtagTrigger"
Write-Output "Website Node default version: $WebsiteNodeDefaultVersion"
Write-Output "Root GitHub URI: $RootGitHubURI"
Write-Output "GitHub Branch: $GitHubBranch"
Write-Output "Twitter Consumer Key: $TwitterConsumerKey"
Write-Output "Twitter Consumer Secret: $TwitterConsumerSecret"
Write-Output "Twitter Access Token Key: $TwitterAccessTokenKey"
Write-Output "Twitter Access Token Secret: $TwitterAccessTokenSecret"
Write-Output "Facebook Consumer Key: $FacebookConsumerKey"
Write-Output "Facebook Consumer Secret: $FacebookConsumerSecret"
Write-Output "Facebook Verification Token: $FacebookVerifyToken"
Write-Output "Instagram Consumer Key: $InstagramConsumerKey"
Write-Output "Instagram Consumer Secret: $InstagramConsumerSecret"
Write-Output "Instagram Verification Token: $InstagramVerifyToken"
Write-Output ""
$Confirm = Read-Host -Prompt "Do you want to proceed with these parameters? (Y) Yes, (N) No"

if ($Confirm -ne 'Y')
{
    Write-Output 'Terminating script...'
    return
}

Write-Output "-----------------------------------------------------"

#endregion

#region Set Template and Parameter location

$Date=Get-Date -Format yyyyMMdd

# Set Root Uri of GitHub Repo (select AbsoluteUri)

$rootUri = New-Object System.Uri -ArgumentList @($RootGitHubURI)

if (![System.Uri]::IsWellFormedUriString($rootUri, [System.UriKind]::Absolute)) {
  throw "Invalid value for root URI: $rootUri"
}

$infrastructureUriString = $rootUri.AbsoluteUri + 'infrastructure/raw/' + $GitHubBranch + '/'
$authorizationUriString = $rootUri.AbsoluteUri + 'authorization/raw/' + $GitHubBranch + '/'
$portalUriString = $rootUri.AbsoluteUri + 'portal-node/raw/' + $GitHubBranch + '/'
$messagingUriString = $rootUri.AbsoluteUri + 'messaging/raw/' + $GitHubBranch + '/'
$webhooksUriString = $rootUri.AbsoluteUri + 'webhooks/raw/' + $GitHubBranch + '/'

# Set template files

$templateRootUri = New-Object System.Uri -ArgumentList @($infrastructureUriString)

Write-Output "Using $templateRootUri to locate templates..."

$ServiceBusTemplate = $templateRootUri.AbsoluteUri + "mcsc-serviceBus.json"
$TwitterPullTemplate = $templateRootUri.AbsoluteUri + "TwitterPull-LogicApp.json"
$FunctionsTemplate = $templateRootUri.AbsoluteUri + "mscs-cf-functions-v2.json"
$WebHookTemplate = $templateRootUri.AbsoluteUri + "mcsc-webhook.json"
$WebAppTemplate = $templateRootUri.AbsoluteUri + "Webapp-Auth.json"
$PortalTemplate = $templateRootUri.AbsoluteUri + "Portal-Webapp-config.json"

if ($UseParameterFiles -eq 'Y')
{
    # Set parameter files

    $parameterRootUri = New-Object System.Uri -ArgumentList @($infrastructureUriString + 'parameters/')
    
    Write-Output "Using $parameterRootUri to locate parameter files..."

    $environmentFileName = $null

    if ($Environment -ne $null -and $Environment -ne '') {
        $environmentFileName = '.' + $Environment
    } else {
        $environmentFileName = ''
    }

    $ServiceBusParameters = $parameterRootUri.AbsoluteUri + 'mcsc-serviceBus' + $environmentFileName + '.parameters.json'
    $TwitterPullParameters = $parameterRootUri.AbsoluteUri + 'TwitterPull-LogicApp' + $environmentFileName + '.parameters.json'
    $FunctionsParameters = $parameterRootUri.AbsoluteUri + 'mscs-cf-functions-v2' + $environmentFileName + '.parameters.json'
    $WebHookParameters = $parameterRootUri.AbsoluteUri + 'mcsc-webhook' + $environmentFileName + '.parameters.json'
    $WebAppParameters = $parameterRootUri.AbsoluteUri + 'Webapp-Auth' + $environmentFileName + '.parameters.json'
    $PortalParameters = $parameterRootUri.AbsoluteUri + 'Portal-Webapp-config' + $environmentFileName + '.parameters.json'
}

#endregion

Write-Output  ''
Write-Output  '*****************************************************'
Write-Output  '             Resource Group'
Write-Output  '*****************************************************'

#region Create the resource group

# Start the deployment
Write-Output "Starting deployment..."

Get-AzureRmResourceGroup -Name $ResourceGroupName -ev notPresent -ea 0  | Out-Null

if ($notPresent) {
    Write-Output "Could not find resource group '$ResourceGroupName' - will create it."
    Write-Output "Creating resource group '$ResourceGroupName' in location '$Location'..."
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Force | out-null
}
else {
    Write-Output "Using existing resource group '$ResourceGroupName'"
}

#endregion

Write-Output  ''
Write-Output  '*****************************************************'
Write-Output  '             Database'
Write-Output  '*****************************************************'

#region Create DB account, databases and collections

# DB & collections names in the CosmosDB Account
$reportingdatabaseName = "reporting"
$userdatabaseName = "user"
$eventscollectionName = "events"
$socialscollectionName = "socials"

# Create a MongoDB API Cosmos DB account

Write-Output "Deploying CosmosDB account..."

#$value=az cosmosdb check-name-exists --name $DBAccountName | out-null

#if ($value -ne "true")
#{
    az cosmosdb create --name $DBAccountName --kind GlobalDocumentDB --resource-group $resourceGroupName --max-interval 10 --max-staleness-prefix 200 | out-null
#}

# Create a database

Write-Output "Deploying '$reportingdatabaseName' database..."
$value = az cosmosdb database exists --db-name $reportingdatabaseName --resource-group-name $resourceGroupName --name $DBAccountName | out-null

if ($value -ne "true")
{
    az cosmosdb database create --name $DBAccountName --db-name $reportingdatabaseName --resource-group $resourceGroupName | out-null
}

# Create a database

Write-Output "Deploying '$userdatabaseName' database..."

$value = az cosmosdb database exists --db-name $userdatabaseName --resource-group-name $resourceGroupName --name $DBAccountName | out-null

if ($value -ne "true")
{
    az cosmosdb database create --name $DBAccountName --db-name $userdatabaseName --resource-group $resourceGroupName | out-null
}

Write-Output  "Deploying '$eventscollectionName' collection..."

# Create a collection

$value = az cosmosdb collection exists --collection-name $eventscollectionName --db-name $reportingdatabaseName --resource-group-name $resourceGroupName --name $DBAccountName | out-null

if ($value -ne "true")
{
    az cosmosdb collection create --collection-name $eventscollectionName --name $DBAccountName --db-name $reportingdatabaseName --resource-group $resourceGroupName | out-null
}

# Create a collection

Write-Output  "Deploying '$socialscollectionName' collection..."

$value = az cosmosdb collection exists --collection-name $socialscollectionName --db-name $userdatabaseName --resource-group-name $resourceGroupName --name $DBAccountName | out-null

if ($value -ne "true")
{
    az cosmosdb collection create --collection-name $socialscollectionName --name $DBAccountName --db-name $userdatabaseName --resource-group $resourceGroupName | out-null
}

#endregion

Write-Output  ''
Write-Output  '*****************************************************'
Write-Output  '             Infrastructure'
Write-Output  '*****************************************************'

#region Deployment of Service bus

Write-Output "Deploying Service Bus..."
$DeploymentName = 'ServiceBus-'+ $Date

$Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $ServiceBusTemplate -TemplateParameterObject `
    @{ `
        serviceBusNamespaceName = $serviceBusNamespace.ToString(); `
        tofilter_queue_name="toFilter"; `
        tostructure_queue_name="toStructure"; `
        tostore_queue_name="toStore"; `
        augment_topic_name="toAugment"; `
    } -Force

Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

#region Deployment of Twitter Pull

Write-Output "Deploying Twitter Pull Logic App..."
$DeploymentName = 'TwitterPull-'+ $Date

$Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $TwitterPullTemplate -TemplateParameterObject `
    @{ `
        logicAppName=$TwitterPullLogicAppName.ToString(); `
        serviceBusNamespaceName=$serviceBusNamespace.ToString(); `
        serviceBusConnectionName="serviceBusConnection"; `
        serviceBusQueueName="toFilter"; `
        twitterConnectionName="twitterConnection"; `
        twitterHashtag=$TwitterHashtagTrigger.ToString(); `
    } -Force

Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

#region Deployment of Azure Functions

Write-Output "Deploying Azure Function..."
$DeploymentName = 'Functions-'+ $Date

$Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $FunctionsTemplate -TemplateParameterObject `
    @{ `
        functionAppsName=$FunctionName.ToLower(); `
        storageAccountType="Standard_LRS"; `
        cosmosDBAccountName=$DBAccountName.Tostring(); `
        serviceBusNamespaceName=$serviceBusNamespace.ToString(); `
        facebookToken=$FacebookVerifyToken.ToString(); `
        TwitterConsumerKey=$TwitterConsumerKey.ToString(); `
        TwitterConsumerSecret=$TwitterConsumerSecret.ToString(); `
        TwitterAccessTokenKey=$TwitterAccessTokenKey.ToString(); `
        TwitterAccessTokenSecret=$TwitterAccessTokenSecret.ToString(); `
        instagramToken=$InstagramVerifyToken.ToString(); `
        repoURL= $rootUri.AbsoluteUri + 'messaging'; `
        branch=$GitHubBranch.ToString(); `
    } -Force

Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

#region Deployment of Web Hook

Write-Output "Deploying Web Hook..."
$DeploymentName = 'WebHook-'+ $Date

$Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $WebHookTemplate -TemplateParameterObject `
    @{ `
        functionAppsName=$WebhookName.ToString(); `
        storageAccountType="Standard_LRS"; `
        serviceBusNamespaceName=$serviceBusNamespace.ToString(); `
        facebookToken=$FacebookVerifyToken.ToString(); `
        instagramToken=$InstagramVerifyToken.ToString(); `
        repoURL=$rootUri.AbsoluteUri + 'webhooks'; `
        branch=$GitHubBranch.ToString(); `
    } -Force

Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

#region Deployment of Web App

Write-Output "Deploying Web Application: Authorization..."
$DeploymentName = 'WebAppAuth-'+ $Date

if ($UseParameterFiles -eq 'Y') {
    $Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $WebAppTemplate -TemplateParameterUri $WebAppParameters -Force
}
else {
    $Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $WebAppTemplate -TemplateParameterObject `
    @{ `
        sites_MCSC_Authorization_name=$WebAppAuthName.ToString(); `
        cosmosDBAccountName=$DBAccountName.ToString(); `
        TWITTER_CONSUMER_KEY=$TwitterConsumerKey.ToString(); `
        TWITTER_CONSUMER_SECRET=$TwitterConsumerSecret.ToString(); `
        FACEBOOK_CONSUMER_KEY=$FacebookConsumerKey.ToString(); `
        FACEBOOK_CONSUMER_SECRET=$FacebookConsumerSecret.ToString(); `
        INSTAGRAM_CONSUMER_KEY=$InstagramConsumerKey.ToString(); `
        INSTAGRAM_CONSUMER_SECRET=$InstagramConsumerSecret.ToString(); `
        IG_VERIFY_TOKEN=$InstagramVerifyToken.ToString(); `
        WEBSITE_NODE_DEFAULT_VERSION=$WebsiteNodeDefaultVersion.ToString(); `
        repoURL=$rootUri.AbsoluteUri + 'authorization'; `
        branch=$GitHubBranch.ToString(); `
    } -Force
}
Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

#region Deployment of Web App Portal

Write-Output "Deploying Web App Portal..."
$DeploymentName = 'WebAppPortal-'+ $Date

$Results = New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateUri $PortalTemplate -TemplateParameterObject `
    @{ `
        sites_MCSC_Portal_name=$WebAppPortalName.ToLower(); `
        WEBSITE_NODE_DEFAULT_VERSION=$WebsiteNodeDefaultVersion.ToString(); `
        repoURL=$rootUri.AbsoluteUri + 'portal-node'; `
        branch=$GitHubBranch.ToString(); `
    } -Force

Write-Output $Results.DeploymentName ' completed with provisioning state : ' $Results.ProvisioningState 
Write-Output  '*****************************************************'

#endregion

$endtime = get-date
$procestime = $endtime - $starttime
$time = "{00:00:00}" -f $procestime.Minutes
write-output "Deployment completed in '$time' "