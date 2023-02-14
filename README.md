# orders_infrastructure
This repository hosts the terraform configuration files for the following resources of the orders project:

* The Azure resources:
  * An Azure VM with HAproxy and a public IP.
  * An AKS cluster.
  * An Azure Database for MySQL - Flexible Server.
  * An Azure VM to manage the DB
  * An Azure Storage Account, with 2 NFS shares, one for sessions persistance, the other for resumes.
  * Additional necessary Azure resources.

* The Kubernetes resources:
  * The webapp deployment.
  * The service.
  
* Cloudflare DNS A records.

