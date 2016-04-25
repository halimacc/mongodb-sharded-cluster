$resourceGroupName="amsc-group-35"
New-AzureRmResourceGroup -Name $resourceGroupName -Location "East Asia"

$storageAccountPrefix="mscb"
$configServersSize="Small"
$shardCount=2;
$shardSize="Small";
$routerCount=2;
$osFamily="UbuntuServer14.04LTS";
$adminUsername="azureuser";
$adminPassword="User@123";

$params=@{
	storageAccountPrefix=$storageAccountPrefix;
	configServersSize=$configServersSize;
	shardCount=$shardCount;
	shardSize=$shardSize;
	routerCount=$routerCount;
	osFamily=$osFamily;
	adminUsername=$adminUsername;
	adminPassword=$adminPassword;
}

New-AzureRMResourceGroupDeployment -Name mongodb-sharded-cluster -ResourceGroupName $resourceGroupName -TemplateFile .\azuredeploy.json -TemplateParameterObject $params

for($i=0; $i -lt $routerCount; $i++){
	$ipaddr = Get-AzureRmPublicIpAddress -Name "router$i-pubip" -ResourceGroupName $resourceGroupName
	echo "router$i : $($ipaddr.IpAddress):27017"
}