#!/system/bin/sh
# NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}
CONFIG=$MODDIR/build/etc/mdns.d/ssh.service
NAMEOFHOST=Pixel
PIDNAME=mdnsd

echo $MODDIR
echo $CONFIG

# This script will be executed in late_start service mode
# And infinite loop until it's killed.
while true
do
	# get ipaddr of wlan0
	IPADDR=$(ifconfig | grep wlan0 -C1 | awk '{print }' | grep 'inet addr' | cut -d: -f2 | awk '{ print $1 }')	

	# log IP ADDRESS to logging.txt
	date | awk '{print $4}' | xargs echo ipaddr: $IPADDR $1 >> $MODDIR/logging.txt

	# get the exact PID number of mdnsd
	PGREPR=$(pgrep -x $PIDNAME)

	# check if ipaddr string is empty,
	# if so, means the either not connected to a wifi network or hotspot is not active
	if [ -z $IPADDR ]; then	

		date | awk '{print $4}' | xargs echo wifi off $1 >> $MODDIR/logging.txt

		# if mdnsd already running, kill it, 
		# and set the hostname to localhost, log it, but don't start mdnsd, since there is no discovery possible
		if pgrep $PIDNAME > /dev/n
			pgrep $PIDNAME | xargs killull; then
			hostname localhost
			date | awk '{print $4}' | xargs echo PID killed $1 >> $MODDIR/logging.txt
		fi
	else

		# If $IPADDR is not empty, it means that the Wi-Fi or hotspot is active,
		# so the script checks if there is no process running with the name $PIDNAME (mdnsd)
		# if there is no process running, then start the mdnsd service
		if ! pgrep $PIDNAME > /dev/null; then
			date | awk '{print $4}' | xargs echo program start $1 >> $MODDIR/logging.txt
			pgrep $PIDNAME | xargs echo PID mdnsd: $1 >> $MODDIR/logging.txt
			hostname $NAMEOFHOST

			# replace the ip address in the config file and start the mdnsd service
			LD_LIBRARY_PATH=$MODDIR/build/lib $MODDIR/build/sbin/mdnsd $CONFIG
		fi
	fi
	sleep 10
done
