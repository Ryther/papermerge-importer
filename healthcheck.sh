#!/usr/bin/with-contenv bash
# shellcheck shell=bash

source /tmp/healthcheck.status
echo "returnCode=${returnCode}"

case $returnCode in
    0)
        echo "returnCode=${returnCode}"
        exit 0
    ;;
    *)
        echo "returnCode=${returnCode}"
        exit 1
    ;;
esac
