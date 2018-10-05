# Barracuda CloudGen Firewall and Web Application Firewall - Blue / Green deployment

## Introduction
Since the begining of time people have tried to automate tasks. Also in computer sience we have seen this from the early days. One limition was the infrastructure that needed to be in place for automation to commence. With virtualisation and public cloud this automation has come full circle and we can now deploy, manage, redeploy everything using automation techniques. We can descibe the operating environment in code, validate it, test it, document it and deploy it from a code repository. 

This is a giant change compared to the typical laborious deployment of infrastructure through cli, web ui, client or other. 

The purpose of this demo is to showcase how you can create, configure and secure your whole environment from code.

![CGF Azure Network Architecture](images/cudalab-blue-green.png)

## Prerequisites
The tools used in this setup are HashiCorp Terraform (> 0.11.x) and RedHat Ansible (> 2.x). Both tools have their pro's and con's. Working together they help maintaining the state of your infrastructure and the ensures the configuration is correct. The deployment can be done from either a bash shell script or from any CI tool. In our case we used Visual Studio Team Services (VSTS). The LINUX VSTS agent requires the Ansible and Terraform tools to be installed as well as the VSTS agent.

## Deployed resources
Following resources will be created by this deployment per color:
- One virtual network with CGF, WAF, WEB and SQL subnets
- Routing for the WEB and SQL subnets
- One CGF virtual machine with a network interface and public IP in a Availability Set
- One WAF virtual machine with a network interface and public IP in a Availability Set
- One WEB Linux virtual machine with a network interface
- One SQL Linux virtual machine with a network interface
- Two external Azure Basic Load Balancer, containing either the CGF or WAF virtual machines with a public IP and services for HTTP, HTTPS IPSEC and/or TINA VPN tunnels
- Azure Traffic Manager to switch from Blue to Green deployment and back

## Deployment

Deployment of this environment is possible via the Azure Cloud Shell. It is also possible via the a system that has Terraform and Ansible installed like a docker image (jvhoof/cloudgen-essentials). However for this deployment you will need to pass the credentials for Azure via the command line or environment variables. This is done automatically in Azure Cloud Shell. 

You can also integrate the deployment of the Blue or Green environments into Azure DevOps or another CI/CD tools. 

The package provides a deploy.sh and destroy.sh scripts which will build or remove the whole setup per color when the correct arguments are supplied as well as the correct environment variables are set. For Azure DevOps the yaml files are provided.

### Azure CLI

To deploy via Azure Cloud Shell you can connect via the Azure Portal or directly to [https://shell.azure.com/](https://shell.azure.com/). 

- Start up Azure Cloud Shell from the Azure Portal or go directly to [https://shell.azure.com](https://shell.azure.com/)
- Download the latest version of the Quickstart templates in the persistant clouddrive and run the deployment script:

blue: `cd ~/clouddrive/ && wget -qO- https://github.com/jvhoof/quickstart-blue-green-azure/archive/master.zip | jar xv && cd ~/clouddrive/quickstart-blue-green-azure-master/ && ./deploy.sh -b`
green: `cd ~/clouddrive/ && wget -qO- https://github.com/jvhoof/quickstart-blue-green-azure/archive/master.zip | jar xv && cd ~/clouddrive/quickstart-blue-green-azure-master/ && ./deploy.sh -g`

- Answer the questions asked by the script on the following variables: location, prefix and password.

![Azure Cloud Shell Bash Edition](images/azurecloudshell1.png)

## deploy.sh and destroy.sh Parameters
The script requires certain environment variables as well as some arguments. 

| Argument | Deploy | Destroy | Parameter Name | Description
|---|---|---|---|---
-b | X | X | DEPLOYMENTCOLOR BLUE | Which version do you want to deploy... blue
-g | X | X | DEPLOYMENTCOLOR GREEN | Which version do you want to deploy... green

## Environment Variables

| Variable Name | Description
|---|---
TF_VAR_LOCATION | Azure datacenter location to deploy the environment
TF_VAR_PREFIX | Prefix text for all deployed resources
TF_VAR_TMDNSNAME | Azure Traffic Manager DNS name
DOWNLOADSECUREFILE1_SECUREFILEPATH | The location of the SSH private key used to connect to the backend servers
