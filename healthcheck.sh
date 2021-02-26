#!/usr/bin/with-contenv bash
# shellcheck shell=bash

returnValue=$(<"/tmp/healthcheck.status")
case $returnValue in
    0)
        exit 0
    ;;
    *)
        exit 1
    ;;
esac
