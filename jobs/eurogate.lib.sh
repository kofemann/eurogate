#!/bin/sh
#############################################################
#
#   try to find  java
#
checkForJava() {

   java=`findBinary java /usr/java/bin /usr/lib/java/bin`
   if [ $? -ne 0 ] ; then echo "Couldn't find java" ; exit 4 ; fi
   JAVA=${java}
#
#  find the javaclasses
#
   checkJava || return $?
   
}
#
#############################################################
#
#   find the logdirectory
#
findLogDir() {
   if [ \( -z "${logdir}"   \) -o \
        \( ! -d "${logdir}" \) -o \
        \( ! -w "${logdir}" \)      ] ; then
      LOGDIR=/dev/null
   else
      LOGDIR=${logdir}
   fi
   echo " * chosing Logdirectory : $LOGDIR"
   return 0
}
#############################################################
#
#    the database root
#
prepareDbSimMode() {

   if [ -z "${databaseRoot}" ] ; then
      echo "Database Root not specifed" 1>&2
      return 2
   fi
   if [ ! -w "${databaseRoot}" ] ; then
      echo "Database Root not writable" 1>&2
      return 2
   fi
   if [ -z "`ls ${databaseRoot}`" ] ; then
      echo " * Creating new Database"
      mkdir -p ${databaseRoot}/store
      mkdir -p ${databaseRoot}/pvr/stk
      mkdir -p ${databaseRoot}/pvl
      mkdir -p ${databaseRoot}/mover
   fi 
   return 0   
}
#############################################################
#
#   try to find  ssh
#
checkForSsh() {
   ssh=`findBinary ssh /usr/bin`
   if [ $? -ne 0 ] ; then echo "Couldn't find ssh" 1>&2 ; return 4 ; fi
   SSH=${ssh}
   #
   #  the ssh keys
   #
   if [ \( -z "${keyBase}"              \) -o \
        \( ! -f "${keyBase}/server_key" \) -o \
        \( ! -f "${keyBase}/host_key"   \)    ] ; then
      echo " ! The keyBase is not defined, or keys not yet created " 1>&2
      echo " ! Please read eurogateSetup.template for the neccessary infos !" 1>&2 
      return 3
   fi
   return 0
}
#
switchSimMode() {
   if [ \( -z "${javaOnly}" \) -o \( "${javaOnly}" = "true" \) ] ; then
      echo " * Chosing javaOnly Movers" 1>&2
   elif [ "${javaOnly}" != "false" ] ; then
      echo " ! The javaOnly variable needs to be " 2>&1 
      echo " ! set true of false ( and not ${javaOnly} )" 2>&1
      return 5
   else 
      if [ \( -z "${sharedLibraries}" \) -o
           \( ! -d "${sharedLibraries}"  \) ] ; then
         echo " ! javaOnly=false  needs a valid sharedLibrary directory" 1>&2
         return 5
      fi
      echo " * Chosing 'real Movers in simulation mode'" 1>&2
      export LD_LIBRARY_PATH
      LD_LIBRARY_PATH=${sharedLibrary}
   fi
   return 0
}
#
#
#
##################################################################
#
#       eugate.check
#
eurogateCheck() {
   checkForSsh || return $?
   $SSH -p $sshPort -c blowfish -o "FallBackToRsh no" localhost <<! >/dev/null 2>&1
      exit
      exit
!
   return $?
}
##################################################################
#
#       eugate.stop
#
eurogateStop() {
#
   checkForSsh  || exit $?
#
   echo "Trying to halt Eurogate"
   $SSH -p $sshPort -c blowfish -o "FallBackToRsh no" localhost <<!  1>/dev/null 2>&1
       kill System
!
  if [ $? -ne 0 ] ; then
     echo "System already stopped" 1>&2
     exit 3
  fi
  return 0
}
##################################################################
#
#       eugate.initPvl
#
eurogateExecStore() {
#
   checkSsh  || exit $?
   checkVar  sshPort || exit $?
#
   $SSH -p $sshPort -o "FallBackToRsh no" localhost <<!
       exit
       set dest MAIN-store
       $* 
exit
exit
!
  if [ $? -ne 0 ] ; then
     echo "Init Failed" 1>&2
     exit 3
  fi
  return 0
}
eurogateInitPvl() {
#
#   checkSsh  || exit $?
   checkVar  pvlDbPort || exit $?
#
   echo "Trying to InitPvl Database"
   $SSH -p $pvlDbPort -c blowfish -o "FallBackToRsh no" localhost <<!  1>/dev/null 2>&1
       exec context initPvlDatabase
       exit
       exit
!
  if [ $? -ne 0 ] ; then
     echo "Init Failed" 1>&2
     exit 3
  fi
  return 0
}
eurogateDeletePvl() {
   checkVar databaseRoot || exit $?
   rm -rf ${databaseRoot}/pvl/* >/dev/null 2>/dev/null
   return 0 
}

##################################################################
#
#       eurogate start
#
eurogateStart() {
   #
   # we need some variables
   #
#   checkVar masterBatch moverBatch master mover masterHost masterPort || exit 5
   #
   checkVar pvlDbPort sshPort clientPort || exit $?
   #
   #
   #  run the spy/telnet server if we can find the spyPort/telnetPort
   #
   if [ ! -z "$spyPort" ] ; then
      SPY_IF_REQUESTED="-spy $spyPort"
   fi
   if [ ! -z "$telnetPort" ] ; then
      TELNET_IF_REQUESTED="-telnet $telnetPort"
   fi
   #
   if [ ! -f "${cellBatch}" ] ; then
      echo " ! Can't find our cell batchfile  ${cellBatch}" 1>&2
      exit 4
   fi
   #
   # check for java and ssh
   #
   checkForJava || exit $?
   checkForSsh  || exit $?
   findLogDir
   switchSimMode || exit $?
   prepareDbSimMode || exit $?
   #
   #
   echo "Trying to start Eurogate"
   printf "Please wait ... "
   #
   eurogateCheck
   if [ $? -eq 0 ] ; then
      echo "System already running"
      exit 4
   fi
   #
   #
   #
   if [ "${master}" = "yes" ] ; then
   
      domainName=euroGate
      log=$LOGDIR/${domainName}.log
      rm -rf $log >/dev/null 2>/dev/null
      touch ${log} >/dev/null 2>/dev/null
      if [ $? -ne 0 ] ; then
         echo "Not allowed to write logfile : ${log}. Using dumpster" 1>&2
         log=/dev/null
      fi
      #
      BATCHFILE=${cellBatch}
      if [ ! -f "$BATCHFILE" ] ; then
          echo "Cell Batchfile not found : $BATCHFILE" 1>&2
          exit 4
      fi
      nohup $JAVA  dmg.cells.services.Domain $domainName \
               -param setupFile=$setupFilePath \
                      thisDir=${thisDir}  \
               -batch $BATCHFILE  \
               -routed \
               $SPY_IF_REQUESTED  $TELNET_IF_REQUESTED >$log 2>&1 &
#
      for c in 5 4 3 2 1 0 ; do printf "${c} " ; sleep 1 ; done 
      printf "\n" 
      x=`tail -3 $log | grep PANIC`
      if [ ! -z "$x" ] ; then
         echo ""
         echo " ------ Infos from Logfile ($log) ---------"
         echo ""
         tail -5 $log
         exit 1
      else
         echo " * Eurogate started "
      fi
   fi
   if [ "${mover}" = "yes" ] ; then
      BATCHFILE=${jobs}/$moverBatch
      if [ ! -f "$BATCHFILE" ] ; then
          echo "Cell Batchfile not found : $BATCHFILE" 1>&2
          exit 4
      fi
      for moverVersion in 0 1  
      do
         domainName=euroMover${moverVersion}
         log=$LOGDIR/${domainName}.log
         rm -rf $log >/dev/null 2>/dev/null
         if [ $? -ne 0 ] ; then
            echo "Not allowed to write logfile : ${log}. Using dumpster" 1>&2
            log=/dev/null
         fi
         #
         nohup $JAVA  dmg.cells.services.Domain euroMover${moverVersion} \
                  -param setupFile=${setupFilePath} \
                         thisDir=${thisDir}  \
                         moverVersion=${moverVersion} \
                  -batch $BATCHFILE  \
                  -connect2 ${masterHost} ${masterPort} \
                  -routed \
                  >$log 2>&1 &   
      done
   fi
}
##################################################################
#
#       eurogate login
#
eurogateLogin() {
#............
#
   checkForSsh  || exit $?
#
  $SSH -p $sshPort -c blowfish -o "FallBackToRsh no" localhost
  return $?
}
#

eurogateHelp() {
   echo "Usage : eurogate start"
   echo "        eurogate login"
   echo "        eurogate initPvl"
   echo "        eurogate deletePvl"
   echo "        eurogate stop"
   return 0
}
eurogateSwitch() {
   case $1 in
     *start)       eurogateStart $* ;;
     *stop)        eurogateStop  $* ;;
     *login)       eurogateLogin  $* ;;
     *initPvl)     eurogateInitPvl  $* ;;
     *deletePvl)   eurogateDeletePvl  $* ;;
     *execStore)   shift ; eurogateExecStore $* ;;
     *)            eurogateHelp $* ;;
   esac
   return $?
} 
