# This Powershell scripts takes ARM templates for Azure KeyVault as input and creates Azure KeyVault in desired ResourceGroup.
# Once KeyVault is created, it auto generates complex passwords and creates secrets inside Azure KeyVault.

param
(
   [Parameter(Mandatory=$true)]
   [System.String]$TemplateFile,

   [Parameter(Mandatory=$true)]
   [System.String]$ParametersFile,

   [Parameter(Mandatory=$true)]
   [System.String]$ResourceGroupParametersFile,

   [Parameter(Mandatory=$true)]
   [System.String]$DeploymentName

)

# Declare and define variables for admin user of AzureSQLDBServer/SQLServerVM and Virtual Machine
[System.String] $strLocalAdminSecretName1 = 'sql-admin'
[System.String] $strLocalAdminSecretName2 = 'vm-admin'



# Get Resource Group parameters
$objResourceGroupParametersFile = Get-Content -Path $ResourceGroupParametersFile | ConvertFrom-Json
[System.String] $strResourceGroupName = $objResourceGroupParametersFile.parameters.rgName[0].value

# Get the KeyVault Name
$obKeyVaultParametersFile = Get-Content -Path $ParametersFile | ConvertFrom-Json
[System.String] $strKeyVaultName = $obKeyVaultParametersFile.parameters.keyVaultName[0].value

# Check if the KeyVault already exists
Write-Output ('Check if KeyVAult ' + $strKeyVaultName + ' already exists.')
$objKeyVault = Get-AzKeyVault -VaultName $strKeyVaultName -ResourceGroupName $strResourceGroupName -ErrorAction SilentlyContinue

if ($null -eq $objKeyVault)
{
   # Write output
   Write-Output 'Start deploying the Azure KeyVault Resource'

   # Start Azure Deployment
   New-AzResourceGroupDeployment -Name $$DeploymentName -ResourceGroupName $strResourceGroupName -Mode Incremental -TemplateParameterFile $ParametersFile -TemplateFile $TemplateFile -Force -Verbose

   # Write output
   Write-Output 'Finishing the deployment of the Azure KeyVault Resource'
   Write-Output 'Check or create the secret'

   # Check if the admin secret already exists
   $objCloudadminSecret = Get-AzKeyVaultSecret -VaultName $strKeyVaultName -Name $strLocalAdminSecretName -ErrorAction SilentlyContinue

   # Create the KeyVault Secret if required with desired complexity
   if ($null -eq $objCloudadminSecret)
   {
      # Load .NET assembly
      Add-Type -Assembly 'System.Web'

      # Create a strong password
      Write-Output ('Generating password...')
      [System.String] $strLocalAdminPassword = [System.Web.Security.Membership]::GeneratePassword(48, 16)
      [System.Security.SecureString] $sstrLocalAdminPassword = ConvertTo-SecureString $strLocalAdminPassword -AsPlainText -Force

      # Create the secret
      Write-Output ('Creating secret ' + $strLocalAdminSecretName + '...')
      New-AzResourceGroupDeployment -Name 'CreateKeyVaultResource1' -ResourceGroupName $strResourceGroupName -Mode Incremental -TemplateParameterFile $ParametersFile -TemplateFile $TemplateFile -secretName_VMdeployment $strLocalAdminSecretName1 -secretValue_VMdeployment $sstrLocalAdminPassword -Force -Verbose
      New-AzResourceGroupDeployment -Name 'CreateKeyVaultResource2' -ResourceGroupName $strResourceGroupName -Mode Incremental -TemplateParameterFile $ParametersFile -TemplateFile $TemplateFile -secretName_VMdeployment $strLocalAdminSecretName2 -secretValue_VMdeployment $sstrLocalAdminPassword -Force -Verbose

   }
   else
   {
      # Write output
      Write-Output ('The secret ' + $strLocalAdminSecretName + ' already exists. Will not do anything.')
   }
}
else
{
   Write-Output ('KeyVAult ' + $strKeyVaultName + ' already exists. Will not do anything.')
}
