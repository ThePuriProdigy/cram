#! /bin/bash

if [ "${SDE}" = "" -o "$SDE_INSTALL" = "" ]
then
    1>&2 echo "Source your setup script that sets env variables SDE and SDE_INSTALL"
    exit 1
fi
echo "Found directory SDE=${SDE} ..."
echo "Found directory SDE_INSTALL=${SDE_INSTALL} ..."
P4GUIDE="$HOME/p4-guide"
if [ ! -d "${P4GUIDE}" ]
then
    1>&2 echo "No directory ${P4GUIDE} found.  Create a copy of the repo https://github.com/jafingerhut/p4-guide there."
    exit 1
fi
echo "Found directory P4GUIDE=${P4GUIDE} ..."
STDLIB_INC_DIR="${P4GUIDE}/stdlib"

if [ $# -lt 1 ]
then
    1>&2 echo "usage: $0 prog.p4 [ additional p4c options ]"
    exit 1
fi
BASENAME=`basename $1 .p4`
shift

bf-p4c \
    $* \
    -DTOFINO2 \
    -b tofino2 \
    -a t2na \
    --verbose 3 \
    -I${STDLIB_INC_DIR} \
    --program-name ${BASENAME} \
    ${BASENAME}.p4

exit_status=$?
echo "bf-p4c exit status: ${exit_status}"
