#!/bin/sh

. /etc/rc.functions

# Check if snmpd is running
checkproc snmpd
if [ $? -eq 1 ]; then
	START=1
else
	START=0
fi

[ -d /var/run/snmp ] || mkdir -p /var/run/snmp

case "$1" in

    start)
		if [ $START -eq 1 ]; then
			# Start SNMP agent
			# -C      - Don't search for other conf files
			# -c      - Use the given conf file(s)
			# -p      - Save the process ID of the daemon in pidfile
			# -LS i d - Log messages via syslog with facility LOG_DAEMON and level LOG_INFO
			#           to see the Net-SNMP start-up and shutting down message.
			#
			[ -f /var/run/snmp/snmpd.conf ] || cp /opt/snmp/snmpd.conf /var/run/snmp/snmpd.conf
			[ -f /var/run/snmp/snmp.conf ] || cp /opt/snmp/snmp.conf /var/run/snmp/snmp.conf
			
			/opt/snmp/snmpd -C -c "/var/run/snmp/snmpd.conf,/var/run/snmp/snmp.conf"  -p "/var/run/snmp/snmpd.pid" -LS i d
		fi
    ;;
    
    stop)
	    stopproc snmpd
    ;;
    
    *)
	    logger -s -t $0 "parameter $1 unknown"
	    exit 1

esac