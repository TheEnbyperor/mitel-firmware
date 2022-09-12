#!/bin/sh
#
# script that configures the wlan modes required for production tests
#
. /etc/rc.functions

# load modules
    modprobe ath9k

# variables use here
MANU_WLAN_CFG_FILE=/tmp/hostapd.conf

# internal functions

###############################################################################
wlan_off () {
    rm -f ${MANU_WLAN_CFG_FILE}
    killall hostapd >/dev/null 2>&1
    sleep 1
    killall hostapd >/dev/null 2>&1
    sleep 1
}

###############################################################################
wlan_start () {
    if [ ! -f ${MANU_WLAN_CFG_FILE} ]; then
        echo "could not find hostapd configuration file"
        exit -1
    fi
    
    # load module
    setpci -d 168c:* 44.l=0x00000000
    sleep 1
    modprobe ath9k 2>&1 >/dev/null
    sleep 1
    
    # setup mac address
    mac=`interface_report_mac eth0`
    ifconfig wlan0 hw ether $mac
    
    # start hostapd
    hostapd -B -d ${MANU_WLAN_CFG_FILE}
}

###############################################################################
wlan_24_g () {

cat > ${MANU_WLAN_CFG_FILE} << EOF
interface=wlan0
driver=nl80211
bridge=br0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=AastraRfp43
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ctrl_interface=/var/run/hostapd
ieee80211d=1
country_code=DE
ssid=rfp43Manu
ieee80211n=0
hw_mode=g
channel=6
EOF

}

###############################################################################
wlan_24_n () {

cat > ${MANU_WLAN_CFG_FILE} << EOF
interface=wlan0
driver=nl80211
bridge=br0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=AastraRfp43
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ctrl_interface=/var/run/hostapd
ieee80211d=1
country_code=DE
ssid=rfp43Manu
ieee80211n=1
hw_mode=g
ht_capab=[HT20][TX-STBC][RX-STBC1]
channel=6

EOF

}

###############################################################################
wlan_518_n () {

cat > ${MANU_WLAN_CFG_FILE} << EOF
interface=wlan0
driver=nl80211
bridge=br0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=AastraRfp43
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
ctrl_interface=/var/run/hostapd
ieee80211d=1
country_code=DE
ssid=rfp43Manu
ieee80211n=1
hw_mode=a
ht_capab=[HT20][TX-STBC][RX-STBC1]
channel=44

EOF

}

###############################################################################
# do the job

    case "$@" in
        off)
            wlan_off
        ;;
        
        "2.4 g on")
            wlan_off
            wlan_24_g
            wlan_start
        ;;
        
        "2.4 n on")
            wlan_off
            wlan_24_n
            wlan_start
        ;;
        
        "5.18 n on")
            wlan_off
            wlan_518_n
            wlan_start
        ;;
        
        *)
            echo "unknown parameter"
        ;;
    
    esac

