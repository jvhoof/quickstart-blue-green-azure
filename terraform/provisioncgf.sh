#!/bin/bash
{
echo "Starting Cloud Init..."

echo "Barracuda CloudGen Firewall bootstrap."
/opb/cloud-setmip $CGFIP $CGFSM $CGFGW
} >> /tmp/provision.log 2>&1