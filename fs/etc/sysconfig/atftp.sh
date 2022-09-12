#!/bin/sh

. /etc/rc.functions

if [ ! -x /usr/sbin/atftpd ] || [ ! -x /usr/bin/fuseImage ];
then
      exit 1  
fi
    tftpdir="/tmp/tftpboot"
    fusedir=${tftpdir}
    mkdir -p ${fusedir}
    
    case "$1" in
        
        start)
        
            checkproc fuseImage; fuseImageState=$?
            
            if [ $fuseImageState -eq 1 ]; then
                info "starting fuseImage"
                modprobe fuse
                start-stop-daemon -S \
                    -x chrt -- -o 0 fuseImage -o auto_unmount ${fusedir}
            fi

            checkproc atftpd; atftpdState=$?
            
            if [ $atftpdState -eq 1 ]; then
                info "starting tftp server"
                start-stop-daemon -S \
                    -x chrt -- -o 0 atftpd --daemon --maxthread 3 \
                    --user root.root ${tftpdir}
            fi
            
        ;;
        
        stop)
        
            checkproc atftpd; atftpdState=$?
            
            if [ $atftpdState -eq 0 ]; then
                info "stopping tftp server"
                start-stop-daemon -K -n atftpd >/dev/null 2>&1
            fi
            
            checkproc fuseImage; fuseImageState=$?
            
            if [ $fuseImageState -eq 0 ]; then
            	info "stopping fuseImage"
                start-stop-daemon -K -n fuseImage >/dev/null 2>&1
            fi
            
        ;;
        
    esac
    
    