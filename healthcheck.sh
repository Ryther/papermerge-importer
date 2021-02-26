#!/usr/bin/with-contenv bash
# shellcheck shell=bash

source /tmp/healthcheck.status

case $returnCode in
    0)
        exit 0
    ;;
    *)
        exit 1
    ;;
esac
