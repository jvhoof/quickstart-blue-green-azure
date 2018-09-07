#!/bin/bash
{
echo "Starting Barracuda CloudGen Firewall bootstrap."
echo "nameserver 8.8.8.8" > /etc/resolv.conf
curl https://raw.githubusercontent.com/jvhoof/quickstart-blue-green-azure/master/resources/quickstart-$COLOR.par --output /root/quickstart-green.par
cp /root/quickstart-green.par /opt/phion/update/box.par && /etc/rc.d/init.d/phion stop && /etc/rc.d/init.d/phion start
/opb/cloud-setmip $CGFIP $CGFSM $CGFGW
/opb/cloud-restore-license -f
} > /tmp/provision.log 2>&1