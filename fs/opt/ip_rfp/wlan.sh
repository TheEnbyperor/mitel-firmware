#!/bin/sh
#wlan.sh
#
# Created on: Apr 5, 2011
#     Author: calange
#
#
#

#
# get helpful functions
#
. /etc/rc.functions

#
# local functions
#


# remove all interfaces that we have created
interface_cleanup () {

    # remove all vlan interfaces
    for vlanif in `interface_list vlan`
    do
        ifconfig $vlanif down
        vconfig rem $vlanif
    done
    
    for brvlanif in `interface_list brvlan`
    do
        if [ "${brvlanif}" == "${interface}" ]; then
            continue
        fi
        ifconfig $brvlanif down
        brctl delbr $brvlanif
    done
    
}

# create vlan interface and bridge
interface_create () {

    if [ "brvlan${vlanid}" == "${interface}" ]; then
        return
    fi
    
    vconfig set_name_type VLAN_PLUS_VID_NO_PAD
    vconfig add br0 ${vlanid}
    
    brctl addbr brvlan${vlanid}
    brctl setfd brvlan${vlanid} 0
    brctl stp   brvlan${vlanid} off
    brctl addif brvlan${vlanid} vlan${vlanid}
    
    ifconfig vlan${vlanid} up
    ifconfig brvlan${vlanid} up

}

# create and configure mesh
interface_mesh_create() {
    
    meshconfig=`cat ${WLAN_MESH_CFG_FILE}  | cut -d : -f 1`
    meshchannel=`cat ${WLAN_MESH_CFG_FILE} | cut -d : -f 2`
    meshhtmode=`cat ${WLAN_MESH_CFG_FILE}  | cut -d : -f 3`
    
    if [ x${meshconfig} == "xmpp" ]; then
        iw phy phy0 interface add mesh0 type mp mesh_id omm
        iw dev mesh0 set mesh_param mesh_hwmp_rootmode=1
        iw dev mesh0 set channel ${meshchannel} ${meshhtmode}
        brctl addif br0 mesh0
    elif [ x${meshconfig} == "xmp" ]; then
        iw phy phy0 interface add mesh0 type mp mesh_id omm
        iw dev mesh0 set channel ${meshchannel} ${meshhtmode}
        brctl addif br0 mesh0
    else
        false
    fi
    
}

interface_mesh_down() {

    ifconfig mesh0 down
    
}

interface_mesh_up() {
    
    meshconfig=`cat ${WLAN_MESH_CFG_FILE}  | cut -d : -f 1`
    meshchannel=`cat ${WLAN_MESH_CFG_FILE} | cut -d : -f 2`
    meshhtmode=`cat ${WLAN_MESH_CFG_FILE}  | cut -d : -f 3`
    
    if [ x${meshconfig} == "xmpp" ]; then
        ifconfig mesh0 up
        iw dev mesh0 set mesh_param mesh_hwmp_rootmode=1
    elif [ x${meshconfig} == "xmp" ]; then
        ifconfig mesh0 up
    else
        false
    fi
    
}

interface_scan_down() {

    ifconfig wlan0 down
 
}

interface_scan_up() {

    ifconfig wlan0 up
 
}

unset ret

#
# parse the argument list
#
what=$1

case "${what}" in

    module)
        case "$action" in
            load)
                # GREEN IT: leave the D3hot state
                setpci -d 168c:* 44.l=0x00000000
                sleep 1
                if [ -f /var/opt/wlan/ath9k_debug ]; then
                  . /var/opt/wlan/ath9k_debug
                else
                  ath9k_debug=0x00000400
                fi
                modprobe ath9k debug=${ath9k_debug} 2>&1 >/dev/null
                sleep 1
            ;;
            unload)
                ipc 'LED 4 ON ORANGE'
                modprobe -r ath9k 2>&1 >/dev/null
                sleep 1
                # GREEN IT: enter D3hot state
                setpci -d 168c:* 44.l=0x00000003
                sleep 1
            ;;
            *)
                logger -p user.notice -s -t $0 "$1: unknown action $action"
                false
            ;;
        esac
    ;;
    
    hostapd)
        case "$action" in
            config_diff)
                ret=0
                for SSID in 0 1 2 3; do
                    if [ -f ${HOSTAPD_ACL_FILE}.wlan${SSID}.new ] && [ -f ${HOSTAPD_ACL_FILE}.wlan${SSID} ]; then
                        diff ${HOSTAPD_ACL_FILE}.wlan${SSID}.new ${HOSTAPD_ACL_FILE}.wlan${SSID} >/dev/null 2>&1
                        ret=$(($ret + $?))
                        mv -f ${HOSTAPD_ACL_FILE}.wlan${SSID}.new ${HOSTAPD_ACL_FILE}.wlan${SSID}
                    elif [ -f ${HOSTAPD_ACL_FILE}.wlan${SSID}.new ]; then
                        ret=$(($ret + 1))
                        mv -f ${HOSTAPD_ACL_FILE}.wlan${SSID}.new ${HOSTAPD_ACL_FILE}.wlan${SSID}
                    elif [ -f ${HOSTAPD_ACL_FILE}.wlan${SSID} ]; then
                        ret=$(($ret + 1))
                        rm -f ${HOSTAPD_ACL_FILE}.wlan${SSID}
                    fi
                done 
                diff ${HOSTAPD_CFG_FILE}.new ${HOSTAPD_CFG_FILE} >/dev/null 2>&1
                ret=$(($ret + $?))
            ;;
            check)
                start-stop-daemon -K -t -n hostapd 2>&1 >/dev/null
            ;;
            start)
                if [ -f /var/opt/wlan/ath9k_debug ]; then
                  . /var/opt/wlan/ath9k_debug
                else
                  ath9k_debug=0x00000400
                fi
                echo ${ath9k_debug} > /sys/kernel/debug/ieee80211/phy0/ath9k/debug
                # local config ?
                if [ -f ${OM_OPT_DIR}/wlan/hostapd.conf ]; then
                  HOSTAPD_CFG_FILE=${OM_OPT_DIR}/wlan/hostapd.conf
                  logger -p user.notice -s -t $0 "!!! using ${HOSTAPD_CFG_FILE} as hostapd configuration file"
                fi
                iw dev mon.wlan0 del >/dev/null 2>&1
                ifconfig wlan0 down >/dev/null 2>&1
                ifconfig wlan1 down >/dev/null 2>&1
                ifconfig wlan2 down >/dev/null 2>&1
                ifconfig wlan3 down >/dev/null 2>&1
                hostapd -P ${HOSTAPD_PID_FILE} -B ${HOSTAPD_CFG_FILE} ${hostapd_extra_opts}
                ret=$?
            ;;
            stop)
            	 ipc 'LED 4 ON ORANGE'
                start-stop-daemon -K -n hostapd
                sleep 2
                rm -rf /var/run/wlan/hostapd.pid
                true
            ;;
            *)
                logger -p user.notice -s -t $0 "$1: unknown action $action"
                false
            ;;
        esac
    ;;
    
    interface)
        case "$action" in
            cleanup)
                interface_cleanup
            ;;
            
            create)
                interface_create
            ;;
            
            *)
                logger -p user.notice -s -t $0 "$1: unknown action $action"
                false
            ;;
        esac
    
    ;;
    
    mesh)
            case "$action" in
                create)
                    interface_mesh_create
                ;;
                up)
                    interface_mesh_up
                ;;
                *)
                    logger -p user.notice -s -t $0 "$1: unknown action $action"
                    false
                ;;
            esac
    ;;
    
    scan)
            case "$action" in
                down)
                    interface_scan_down
                ;;
                up)
                    interface_scan_up
                ;;
                *)
                    logger -p user.notice -s -t $0 "$1: unknown action $action"
                    false
                ;;
            esac
    ;;
        
    *)
        logger -p user.notice -s -t $0 "unknown action $1"
        false
    ;;

esac

    exit ${ret-$?}

