#!/bin/sh
#
# start/stop the dhcp server
# returns  0: success
#          1: no action needed
#          2: failed
#

. /etc/rc.functions

dhcpdConfTmp="/var/run/omm/udhcpd.conf.tmp"
dhcpdConf="/var/run/omm/udhcpd.conf"

if [ ! -x /usr/sbin/udhcpd ]; then
      exit 2
fi

    case "$1" in
        
        start)
        
            dhcpdStart=0;
        
            diff $dhcpdConfTmp $dhcpdConf >/dev/null 2>&1; dhcpdConfDiff=$?
            if [ $dhcpdConfDiff -ne 0 ]; then
               mv $dhcpdConfTmp $dhcpdConf
               dhcpdStart=1
            else
               rm -f $dhcpdConfTmp
            fi
                      
            checkproc udhcpd; udhcpdState=$?
            if [ $udhcpdState -ne 0 ]; then
               dhcpdStart=1
            fi
            
            if [ $dhcpdStart -eq 1 ]; then
               if [ $udhcpdState -eq 0 ]; then
                  stopproc udhcpd
               fi
               udhcpd -S -I $dhcpdIP $dhcpdConf
               exit 0
            else
               exit 1
            fi

        ;;
        
        stop)
        
            checkproc udhcpd; udhcpdState=$?
            if [ $udhcpdState -eq 0 ]; then
               stopproc udhcpd
               rm -f $dhcpdConf
               exit 0
            else
               exit 1
            fi
            
        ;;
        
        *)
            exit 2
        ;;
        
    esac
    
    exit 2
    