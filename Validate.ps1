<#

.DESCRIPTION
  This script will validate the ARM template.

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [System.String]$TemplateFile,

    [Parameter(Mandatory=$true)]
    [System.String]$ParametersFile,

    [Parameter(Mandatory=$true)]
    [System.String]$ResourceGroupParametersFile

)

$objResourceGroupParametersFile = Get-Content -Path $ResourceGroupParametersFile | ConvertFrom-Json
[System.String] $ResourceGroupName = $objResourceGroupParametersFile.parameters.rgName[0].value

Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterFile $ParametersFile -TemplateFile $TemplateFile -Verbose

