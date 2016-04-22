$resourceGroupName="amsc-group-33"
New-AzureRmResourceGroup -Name $resourceGroupName -Location "East Asia"

$storageAccountPrefix="msctest"
$configServersSize="Small"
$shardCount=2;
$shardSize="XSmall";
$routerCount=1;
$adminUsername="azureuser";
$adminPassword="User@123";

$params=@{
	storageAccountPrefix=$storageAccountPrefix;
	configServersSize=$configServersSize;
	shardCount=$shardCount;
	shardSize=$shardSize;
	routerCount=$routerCount;
	adminUsername=$adminUsername;
	adminPassword=$adminPassword;
}

New-AzureRMResourceGroupDeployment -Name DeployMongoShardedCluster -ResourceGroupName $resourceGroupName -TemplateFile .\azuredeploy.json -TemplateParameterObject $params

$ipaddr = Get-AzureRmPublicIpAddress -Name "router0-pubip" -ResourceGroupName $resourceGroupName

echo "router0: $($ipaddr.DnsSettings.Fqdn):27017"