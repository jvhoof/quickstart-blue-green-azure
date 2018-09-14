#!/bin/bash
echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Deployment of CUDALAB EU configuration in Microsoft Azure using Terraform and Ansible
#
##############################################################################################################
"

# Stop running when command returns error
set -e

PLAN="terraform.tfplan"
PLANATM="terraform-atm.tfplan"
ANSIBLEINVENTORYDIR="ansible/inventory"
ANSIBLEWAFINVENTORYDIR="ansible-waf/inventory"
ANSIBLEINVENTORY="$ANSIBLEINVENTORYDIR/all"
ANSIBLEWEBINVENTORY="$ANSIBLEINVENTORYDIR/web"
ANSIBLESQLINVENTORY="$ANSIBLEINVENTORYDIR/sql"
ANSIBLEWAFINVENTORY="$ANSIBLEWAFINVENTORYDIR/waf"

while getopts "bg" option; do
    case "${option}" in
        b) DEPLOYMENTCOLOR="blue" ;;
        g) DEPLOYMENTCOLOR="green" ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ -z "$DEPLOY_LOCATION" ]
then
    # Input location 
    echo -n "Enter location (e.g. eastus2): "
    stty_orig=`stty -g` # save original terminal setting.
    read location         # read the location
    stty $stty_orig     # restore terminal setting.
    if [ -z "$location" ] 
    then
        location="eastus2"
    fi
else
    location="$DEPLOY_LOCATION"
fi
TF_VAR_LOCATION="$location"
echo ""
echo "--> Deployment in $location location ..."
echo ""

if [ -z "$DEPLOY_PREFIX" ]
then
    # Input prefix 
    echo -n "Enter prefix: "
    stty_orig=`stty -g` # save original terminal setting.
    read prefix         # read the prefix
    stty $stty_orig     # restore terminal setting.
    if [ -z "$prefix" ] 
    then
        prefix="CUDA"
    fi
else
    prefix="$DEPLOY_PREFIX"
fi
TF_VAR_PREFIX="$prefix"
echo ""
echo "--> Using prefix $prefix for all resources ..."
echo ""
rg_cgf="$prefix-RG"

if [ -z "$DEPLOY_PASSWORD" ]
then
    # Input password 
    echo -n "Enter password: "
    stty_orig=`stty -g` # save original terminal setting.
    stty -echo          # turn-off echoing.
    read passwd         # read the password
    stty $stty_orig     # restore terminal setting.
else
    DB_PASSWORD="$DEPLOY_PASSWORD"
    PASSWORD="$DEPLOY_PASSWORD"
    echo ""
    echo "--> Using password found in env variable DEPLOY_PASSWORD ..."
    echo ""
fi

# Generate SSH key
if [ ! -f output/ssh_key ]; then
    ssh-keygen -q -t rsa -b 2048 -f output/ssh_key -C "" -N ""
fi
SSH_KEY_DATA=`cat output/ssh_key.pub`
DOWNLOADSECUREFILE1_SECUREFILEPATH="output/ssh_key"
DOWNLOADSECUREFILE2_SECUREFILEPATH="resources/selfsigned.pkcs12"


echo ""
echo "==> Deployment of the [$DEPLOYMENTCOLOR] environment"
echo ""
SUMMARY="summary-$DEPLOYMENTCOLOR.out"

echo ""
echo "==> Starting Terraform deployment"
echo ""
cd terraform/

echo ""
echo "==> Terraform init"
echo ""
terraform init

echo ""
echo "==> Terraform workspace [$DEPLOYMENTCOLOR]"
echo ""
terraform workspace list
terraform workspace select $DEPLOYMENTCOLOR || terraform workspace new $DEPLOYMENTCOLOR

echo ""
echo "==> Terraform plan"
echo ""
terraform plan --out "$PLAN" \
                -var "PASSWORD=$PASSWORD" \
                -var "DB_PASSWORD=$DB_PASSWORD" \
                -var "SSH_KEY_DATA=$SSH_KEY_DATA" \
                -var "AZURE_CLIENT_ID=$AZURE_CLIENT_ID" \
                -var "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
                -var "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
                -var "AZURE_TENANT_ID=$AZURE_TENANT_ID" \
                -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR" 

echo ""
echo "==> Terraform apply"
echo ""
terraform apply "$PLAN"

echo ""
echo "==> Terraform graph"
echo ""
terraform graph | dot -Tsvg > "../output/graph-$DEPLOYMENTCOLOR.svg"

echo ""
echo "==> Creating inventory directories for Ansible"
echo ""
mkdir -p "../$ANSIBLEINVENTORYDIR"
mkdir -p "../$ANSIBLEWAFINVENTORYDIR"

echo ""
echo "==> Terraform output to Ansible inventory"
echo ""
terraform output ansible_inventory > "../$ANSIBLEINVENTORY"

echo ""
echo "==> Terraform output deployment summary"
echo ""
terraform output deployment_summary > "../output/$SUMMARY"

cd ../
echo ""
echo "==> Ansible configuration"
echo ""
ansible-playbook ansible/all.yml $ANSIBLEOPTS -i "$ANSIBLEINVENTORY" 

echo ""
echo "==> Connectivity verification $DEPLOYMENTCOLOR environment"
echo ""

cd terraform-atm/
echo ""
echo "==> Switch to $DEPLOYMENTCOLOR environment"
echo ""
echo ""
echo "==> Terraform init"
echo ""
echo "BACKEND_STORAGE_ACCOUNT_NAME: [$BACKEND_STORAGE_ACCOUNT_NAME]"
#terraform init \
#  -backend-config="storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
#  -backend-config="container_name=$BACKEND_CONTAINER_NAME" \
#  -backend-config="key=$BACKEND_KEY_TM" \
#  -backend-config="access_key=$BACKEND_ARM_ACCESS_KEY" 

echo ""
echo "==> Terraform plan"
echo ""
#terraform plan --out "$PLANATM" \
#                -var "CCSECRET=$CCSECRET" \
#                -var "PASSWORD=$PASSWORD" \
#                -var "SSH_KEY_DATA=$SSH_KEY_DATA" \
#                -var "AZURE_CLIENT_ID=$AZURE_CLIENT_ID" \
#                -var "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
#                -var "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
#                -var "AZURE_TENANT_ID=$AZURE_TENANT_ID" \
#                -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR"

echo ""
echo "==> Terraform apply"
echo ""
#terraform apply "$PLANATM"
