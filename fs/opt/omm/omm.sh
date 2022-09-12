
#!/bin/sh

. /etc/rc.functions

################################################################################
# handle SIGTERM
#

terminate () {

   info "terminating omm ..."
   start-stop-daemon -K -n ommwatcher > /dev/null 2>&1
   start-stop-daemon -K -n omm > /dev/null 2>&1
   start-stop-daemon -K -n udhcpd > /dev/null 2>&1
   
   exit 0
}

trap terminate TERM

################################################################################
# do the hard work
#

   ulimit -n 5120
   
   ### start the ommwatcher
   if [ -x /opt/omm/ommwatcher ]; then
      start-stop-daemon -K -n ommwatcher > /dev/null 2>&1
      if [ ! -f /tmp/debug-omm -a ! -x /var/run/omm-debug ]; then
        start-stop-daemon -S -b -p ${OMMW_PID_FILE} -m -x /opt/omm/ommwatcher
      fi
   fi
   
   if [ -f ${RFPM_WORK_DIR_OMM_CONF} ]; then
      cp ${RFPM_WORK_DIR_OMM_CONF} ${OMM_CONFIG_FILE}
      rm -f ${RFPM_WORK_DIR_OMM_CONF}
   fi
   
   info "starting omm with params '${OMM_PARAMS}'"
   cd /opt/omm
   if [ -f /tmp/debug-omm ]; then
      eval start-stop-daemon -S -p ${OMM_PID_FILE} -m -x chrt -- -o 0 gdbserver 0.0.0.0:20000 /opt/omm/omm ${OMM_PARAMS}
   elif [ ! -x /var/run/omm-debug ]; then
      eval start-stop-daemon -S -p ${OMM_PID_FILE} -m -x /opt/omm/omm -- ${OMM_PARAMS}
   else 
      while [ 1 ]; do sleep 60; done
   fi
   
   ### tell rfpm that omm exited
   ipc "REQ_NEW_CFG"
   
   ### stop the ommwatcher
   start-stop-daemon -K -n ommwatcher > /dev/null 2>&1
   start-stop-daemon -K -n udhcpd > /dev/null 2>&1
   
   ### receive signal if any
   usleep 200000
   
#
# end of file
################################################################################
