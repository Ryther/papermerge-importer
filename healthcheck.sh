#!/usr/bin/with-contenv bash
# shellcheck shell=bash

source /tmp/healthcheck.status

echo "returnValue=${returnValue}"

case $returnValue in
    0)
        exit 0
    ;;
    *)
        exit 1
    ;;
esac
