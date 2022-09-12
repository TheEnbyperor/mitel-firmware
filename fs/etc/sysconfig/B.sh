#
# B.sh: sourced by run_scripts
#       fill empty variables with reasonable values 
#

    if [ -z "${OM_RfpInterface}" ]; then
        save_env_get
        export OM_RfpInterface="${MASTERIF}"
    fi
    
    if [ -z "${OM_RfpIpNetMask}" ]; then
        eval `/bin/ipcalc --netmask ${OM_RfpIpAddress}`
        export OM_RfpIpNetMask=${NETMASK}
    fi
    
    if [ -z "${OM_RfpIpBroadCast}" ]; then
        eval `/bin/ipcalc --broadcast ${OM_RfpIpAddress} ${OM_RfpIpNetMask}`
        export OM_RfpIpBroadCast=${BROADCAST}
    fi
    
