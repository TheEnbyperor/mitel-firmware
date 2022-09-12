#!/bin/sh
#
#
#
. /etc/rc.functions

local INSTALL_ADDONS=0

# parameter and variable check

if [ -z ${ADDONS} ]; then
    error "variable ADDONS not defined"
    exit 1
fi

if [ ! -f ${ADDONS} ]; then
    error "{ADDONS} not a file"
    exit 1
fi

if [ -z ${1} ]; then
    error "$0 must be called with a parameter"
    exit 1
fi

# all tests passed

install_addons () {

   info "installing addons ..."
   rm -rf /var/opt/addons
   tar -x -j -C /var/opt -f ${ADDONS}
   if [ $? -eq 0 ]; then
      chown -R root.root /var/opt/addons
      info "installing addons done"
   else
      rm -rf /var/opt/addons
      error "installing addons failed"
   fi
   
}

case "$1" in
    install)
      if [ ! -d /var/opt/addons ]; then
         INSTALL_ADDONS=1
      else
         tar -x -j -C /tmp -f ${ADDONS} addons/addons.md5
         cd /var/opt/addons && find . -type f ! -name addons.md5 -exec md5sum {} \; > /tmp/addons/addons-new.md5
         diff -w /tmp/addons/addons.md5 /tmp/addons/addons-new.md5
         if [ $? -ne 0 ]; then
            INSTALL_ADDONS=1
         fi
      fi
      
      if [ $INSTALL_ADDONS -eq 1 ]; then
         install_addons
      else
         info "addons already installed"
      fi
            
      exit 0
    ;;
    
    *)
      error "unknown parameter \"$1\""
      exit 1
    ;;
    
esac    