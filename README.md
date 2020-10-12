# first-project-devops-udacity

### Getting Started
1.	Clone this repository
2.	Create your infrastructure as code
3.	Deploying your infrastructure in Azure
4.	Destroy your infrastructure

### Instructions
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
    •	main.tf: a terraform configuration (virtual network, NIC..., etc), which start off with a provider, in this case is azurerm.
    •	versions.tf: contains the required and the version of the provider used in main.tf
    •	vars.tf: input variables to use in main.tf, among other variables, it the path to the image created by packer.
    •	To deploy the resources:
      •	Into the folder where the files are located and run:
        terraform init: to initialize the terraform working directory and install the provider
        terraform validate : validate Terraform files
        terraform plan : to show and generate an execution plan. You have to enter number of virtual machines you want to deploy.
        terraform plan -out solution.plan : save the plan file with the name solution.plan
        terraform apply “solution.plan” : builds your infrastructure
        
 ### Output
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
