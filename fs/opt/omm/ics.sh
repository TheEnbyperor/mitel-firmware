#!/bin/sh

. /etc/rc.functions

################################################################################
# handle SIGTERM
#

terminate () {

   info "terminating ics ..."
   start-stop-daemon -K -n ics > /dev/null 2>&1
   
   exit 0
}

trap terminate TERM

################################################################################
# do the hard work
#

   ulimit -n 5120
   
   eval info "starting ics"
   cd /opt/omm
   if [ -f /tmp/debug-ics ]; then
      eval start-stop-daemon -S -p ${OMM_PID_FILE} -m -x chrt -- -o 0 gdbserver 0.0.0.0:20000 /opt/omm/ics -i ${OM_RfpInterface}
   else
      eval start-stop-daemon -S -p ${OMM_PID_FILE} -m -x /opt/omm/ics -- -i ${OM_RfpInterface}
   fi
   
   ### receive signal if any
   usleep 200000
   
   ### tell rfpm to renew
   ipc "REQ_NEW_CFG"

#
# end of file
################################################################################
