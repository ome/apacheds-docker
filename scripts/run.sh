#!/usr/local/bin/dumb-init /bin/bash

# Environment variables:
# APACHEDS_VERSION
# APACHEDS_INSTANCE
# APACHEDS_BOOTSTRAP
# APACHEDS_DATA
# APACHEDS_USER
# APACHEDS_GROUP

APACHEDS_INSTANCE_DIRECTORY=${APACHEDS_DATA}/${APACHEDS_INSTANCE}
PIDFILE="${APACHEDS_INSTANCE_DIRECTORY}/run/apacheds-${APACHEDS_INSTANCE}.pid"

# When a fresh data folder is detected then bootstrap the instance configuration.
if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]; then
    mkdir ${APACHEDS_INSTANCE_DIRECTORY}
    cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY}
    chown -v -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_INSTANCE_DIRECTORY}
fi

cleanup(){
    if [ -e "${PIDFILE}" ];
    then
        echo "Cleaning up ${PIDFILE}"
        rm "${PIDFILE}"
    fi
}

trap cleanup EXIT
cleanup

/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds start ${APACHEDS_INSTANCE}
sleep 2  # Wait on new pid

shutdown(){
    echo "Shutting down..."
    /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE}
}

trap shutdown INT TERM
tail -n 0 --pid=$(cat $PIDFILE) -f ${APACHEDS_INSTANCE_DIRECTORY}/log/apacheds.log
