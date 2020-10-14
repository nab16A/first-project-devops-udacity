# Deploying a Web Server in Azure

## Introduction
In this project, you will create an infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.

### Getting Started
1.	Clone this repository
2.	Create your infrastructure as code
3.	Deploying your infrastructure in Azure
4.	Destroy your infrastructure

#### Dependencies
Create an Azure Account
Install the Azure command line interface
Install Packer
Install Terraform

##### Instructions
After you have collected your dependencies, to deploy your web server in Azure:
1.	Check that you have installed the latest version of:
•	cli, run: az --version
•	Terraform, run: terraform -version
•	Packer, run: packer version
2.	In folder packer-template, there are two files:
•	server.json: packer templates written in json-format.
•	myVariables.json: input variables for the packer templates.
•	You can customise the image to deploy by using your credentials in myVariables.json
•	subscription-id and tenant-id are from your Azure account. Or, run: az account list
•	To obtain client-id and client-secret, you have to create a service principal using a custom name, run:
az ad sp create-for-rbac -n “custom-name”
•	To create an image for a virtual machine to be built, into the folder where the files are located and run: 
packer build -force -var-file=myVariables.json server.json 
To understand the flags in this command, run:
packer --help
To access the image, run:
az image list
To remove it, run:
az image delete -g your-resource-group -n your-image-name 
3.	In folder terraform-template, there are three files:
•	main.tf: a terraform configuration (virtual network, NIC..., etc), which start off with a 
•	provider, in this case is azurerm.
•	versions.tf: contains the required provider and its version used in main.tf
•	vars.tf: contains the input variables which serves as parameters for a Terraform module. The benefit of this file is that you can customized the module (main.tf) without altering the source code, and share it with different configurations.
Input variables are like function arguments in other programming languages.
Each input variable accepted by a module has to be declared using a variable block, followed by the name of the variable just after the variable keyword. The name of the variable has to be unique among all variables in the same module. This name is used to assign a value to the variable from outside and to reference the variable's value from within the module.
For example your subscriptionId, tenantId or resource_group_name, etc
•	To deploy the resources:
•	Into the folder where the files are located and run:
terraform init: to initialize the terraform working directory and install the provider
terraform validate : validate Terraform files
terraform plan : to show and generate an execution plan. You have to enter number of virtual machines you want to deploy.
terraform plan -out solution.plan : save the plan file with the name solution.plan
terraform apply “solution.plan” : builds your infrastructure
4.	templates folder contains all template files regrouped in a single folder.

###### Output
In your Azure account:
•	ddosplan
•	LoadBalancer
•	NetworkWatcher_your-location
•	project-disk-01 (when you enter 1)
•	project-osdisk-01 (when you enter 1)
•	project-vm-01 (when you enter 1)
•	project-vnet
•	public-ip
•	securityGroup
•	vnetproject-nic
•	your-packer-image

