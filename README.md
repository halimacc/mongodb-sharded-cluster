# Deploy MongoDB sharded cluster on Azure
<!-- <a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhalimacc%2Fmongodb-sharded-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a> -->

This template creates a sharded cluster MongoDB deployment on Azure.

Deploy
------
#####Deploy with Azure Powershell#####
Open Azure Powershell and run below commands
```
Login-AzureRMAccount
.\deploy-mongo-sharded-cluster.ps1
```

Architecture
------------
Below picture shows MongoDB sharded cluster architecture. For more infomation, please refer to [Official Document](https://docs.mongodb.org/manual/core/sharding-introduction/).
<img src="https://docs.mongodb.org/manual/_images/sharded-cluster-production-architecture.png"/>