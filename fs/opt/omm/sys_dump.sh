#!/bin/sh

   PATH=/bin:/usr/bin:/sbin

   gzip -9 $1
   
   exit $?