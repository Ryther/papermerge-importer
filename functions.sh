#!/usr/bin/with-contenv bash
# shellcheck shell=bash

log() {
    scriptName=$1
    logLevel=$2
    message=$3

    case $logLevel in
        0)
            logLevel="INFO"
            setHealthcheckStatus 0
        ;;
        1)
            logLevel="INFO"
        ;;
        2)
            logLevel="WARN"
        ;;
        3 | *)
            logLevel="ERR"
            setHealthcheckStatus 1
        ;;
    esac
    
    echo "${scriptName} | ${logLevel} | ${message}"
}

setHealthcheckStatus() {
    returnCode=$1
    > /tmp/healthcheck.status echo "returnCode=${returnCode}"
}

rm -f /tmp/healthcheck.status
