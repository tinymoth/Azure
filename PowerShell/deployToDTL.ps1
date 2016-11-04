<#
 .SYNOPSIS
    Deploys a template to Azure DevTest Labs

 .DESCRIPTION
    Deploys an Azure Resource Manager template to DevTest Labs. It needs to be a DTL template.

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER labName
    The Azure DevTest Lab where the template will be deployed.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [Parameter(Mandatory=$false)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $labName,

 [string]
 $templateFilePath = "template.json",

 [string]
 $parametersFilePath = "parameters.json"
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace ;
}



#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.devtestlab");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Find existing lab
$dtlLab = Find-AzureRmResource -ResourceType "microsoft.devtestlab/labs" -ResourceNameContains $labName
if(!$dtlLab)  {
    throw "Couldn't find the lab '$labname'"
}

$RGName = $dtlLab.ResourceGroupName

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath -Verbose
} 
else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $RGName -TemplateFile $templateFilePath -Verbose
}