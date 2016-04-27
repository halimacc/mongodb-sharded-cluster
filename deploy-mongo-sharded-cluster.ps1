#before running this PowerShell script, you need to 
#1. Login to Azure or AzureChinaCloud first, run the following command:
# 		Login to Azure:					Login-AzureRmAccount
#		Login to AzureChinaCloud:		Login-AzureRmAccount -EnvironmentName AzureChinaCloud
#2. Create a ResourceGroup, run the following command as example:
# 		New-AzureRmResourceGroup -Name "YOUR-RESOURCE-GROUP-NAME" -Location "YOUR-LOCATION"

param(
	[Parameter(Mandatory=$true)]
	[string]$ResourceGroupName,
	[Parameter(Mandatory=$true)]
	[string]$StorageAccountPrefix,
	[Parameter(Mandatory=$true)]
	[string]$ConfigServersSize,
	[Parameter(Mandatory=$true)]
	[int]$ShardCount,
	[Parameter(Mandatory=$true)]
	[string]$ShardSize,
	[Parameter(Mandatory=$true)]
	[int]$RouterCount,
	[Parameter(Mandatory=$false)]
	[string]$OsFamily="UbuntuServer14.04LTS",
	[Parameter(Mandatory=$true)]
	[string]$AdminUsername,
	[Parameter(Mandatory=$true)]
	[string]$AdminPassword
)

$params=@{
	storageAccountPrefix=$StorageAccountPrefix;
	configServersSize=$ConfigServersSize;
	shardCount=$ShardCount;
	shardSize=$ShardSize;
	routerCount=$RouterCount;
	osFamily=$OsFamily;
	adminUsername=$AdminUsername;
	adminPassword=$AdminPassword;
}

$TemplateUri="https://raw.githubusercontent.com/halimacc/mongodb-sharded-cluster/master/azuredeploy.json"

$deployment = New-AzureRMResourceGroupDeployment -Name mongodb-sharded-cluster -ResourceGroupName $resourceGroupName -TemplateUri $TemplateUri -TemplateParameterObject $params

if ($deployment.ProvisioningState -eq "Succeeded")
{
	echo "Deploy MongoDB Sharded Cluster on VM $OsFamily successfully."
}
else
{
	echo "Failed to deploy MongoDB Sharded Cluster on VM $OsFamily."
	#exit 1
}

echo "Router Addresses:"
for($i=0; $i -lt $routerCount; $i++){
	$ipaddr = Get-AzureRmPublicIpAddress -Name "router$i-pubip" -ResourceGroupName $resourceGroupName
	echo "router$i : $($ipaddr.IpAddress):27017"
}
