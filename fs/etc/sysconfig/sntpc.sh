#!/bin/sh

. /etc/rc.functions

	if [ ! -x /opt/sntp/sntpc ]; then
	   exit 1
	fi

	SNTPCONF_NEW=${OM_TMP_DIR}/sntpc/sntpc_tmp.conf
	SNTPCONF=${OM_TMP_DIR}/sntpc/sntpc.conf
	SNTPC_PID_FILE=${OM_PID_DIR}/sntpc.pid
	
	mkdir -p ${OM_TMP_DIR}/sntpc
	
	rm -rf $SNTPCONF_NEW

	while [ $# -gt 0 ]; do
		echo -n " $1" >> $SNTPCONF_NEW
		shift
	done

  	if [ -f $SNTPCONF_NEW ]; then
	    touch $SNTPCONF
	    SNTPPARAMS_NEW=`cat $SNTPCONF_NEW`
	    SNTPPARAMS=`cat $SNTPCONF`
	    checkproc sntpc
        if [ $? -eq 1 ]; then
            SNTPC_START=1
        elif [ "$SNTPPARAMS_NEW" != "$SNTPPARAMS" ]; then
		    SNTPC_START=1
    	else
    	    SNTPC_START=0
		fi
		if [ $SNTPC_START -eq 1 ]; then
			mv $SNTPCONF_NEW $SNTPCONF
	        start-stop-daemon -K -n sntpc >/dev/null 2>&1
	        info "starting sntpc"
	       start-stop-daemon -p ${SNTPC_PID_FILE} -S -b -x /opt/sntp/sntpc -- -d 2 ${SNTPPARAMS_NEW}    
		fi
    else
        info "stopping sntpc"
        start-stop-daemon -K -n sntpc >/dev/null 2>&1
    fi

    rm -rf $SNTPCONF_NEW

