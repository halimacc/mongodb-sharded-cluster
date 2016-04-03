# Deploy MongoDB shared cluster on Azure

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhalimacc%2Fmongodb-sharded-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fhalimacc%2Fmongodb-sharded-cluster%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>

This template creates a sharded cluster MongoDB deployment on Azure. 

Architecture
------------
Below picture shows MongoDB sharded cluster architecture. For more infomation, please refer to [Official Document]("https://docs.mongodb.org/manual/core/sharding-introduction/").
<img src="https://docs.mongodb.org/manual/_images/sharded-cluster-production-architecture.png"/>

Parameters
----------
**uniqueNamePrefix**: unique name prefix for Azure resources in cluster, 3-7 characters.
**adminUsername**: username of administrator for all Ubuntu virtual machines.
**adminPassword**: password of administrator for all Ubuntu virtual machines.
**shardCount**: count of shard component in cluster, fixed to 2 for now.

Notes
-----
**Replica Size**: all replicas are single mongod instance on single virtual machine for now.
**Jumpbox**: this template deploys one query router component for now, and configured it as the default jumpbox of the cluster.
**Virtual Machine**: Standard_D1, Ubuntu 14.04.4-LTS 
