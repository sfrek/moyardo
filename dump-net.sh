xmllint --xpath '//network/ip/@address' /tmp/net-dump.xml > /tmp/variables
xmllint --xpath '//network/ip/@netmask' /tmp/net-dump.xml >> /tmp/variables

. /tmp/variables

ipcalc $address $netmask

# ADDR=xmllint --xpath '//network/ip/@address' /tmp/net-dump.xml | cut -d'"' -f2
# MASK=xmllint --xpath '//network/ip/@netmask' /tmp/net-dump.xml | cut -d'"' -f2





ADDR=$(xmllint --xpath '//network/ip/@address' /tmp/net-dump.xml | cut -d'"' -f2)
MASK=$(xmllint --xpath '//network/ip/@netmask' /tmp/net-dump.xml | cut -d'"' -f2)

echo "---- $ADDR ----"
echo "---- $MASK ----"

os_base=$(lsb_release -si | tr [:upper:] [:lower:])
echo ${os_base}

ipcalc ${ADDR} ${MASK} | awk '/Network/ {print $2}'
