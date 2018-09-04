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

#SECRET="/ssh/secrets.tfvars"
#STATE="terraform.tfstate"

while getopts "b:d:v:w:x:y:z:" option; do
    case "${option}" in
        d) DB_PASSWORD="$OPTARG" ;;
        v) AZURE_CLIENT_ID="$OPTARG" ;;
        w) AZURE_CLIENT_SECRET="$OPTARG" ;;
        x) AZURE_SUBSCRIPTION_ID="$OPTARG" ;;
        y) AZURE_TENANT_ID="$OPTARG" ;;
        z) DEPLOYMENTCOLOR="$OPTARG" ;;
    esac
done

cd terraform/
echo ""
echo "==> Starting Terraform deployment"
echo ""

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
echo "==> Terraform destroy"
echo ""
terraform destroy -var "PASSWORD=$PASSWORD" \
                  -var "PASSWORD=$PASSWORD" \
                  -var "DB_PASSWORD=$DB_PASSWORD" \
                  -var "AZURE_CLIENT_ID=$AZURE_CLIENT_ID" \
                  -var "AZURE_CLIENT_SECRET=$AZURE_CLIENT_SECRET" \
                  -var "AZURE_SUBSCRIPTION_ID=$AZURE_SUBSCRIPTION_ID" \
                  -var "AZURE_TENANT_ID=$AZURE_TENANT_ID" \
                  -var "DEPLOYMENTCOLOR=$DEPLOYMENTCOLOR" \
                  -auto-approve 
