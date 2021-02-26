#!/usr/bin/with-contenv bash
# shellcheck shell=bash

source ./functions.sh

if [ -z "${PAPERMERGE_HOST+x}" ]; then
    log "$0" 2 "Cannot find PAPERMERGE_HOST env variable"
    exit
fi

if [ -z "${AUTH_TOKEN+x}" ]; then
    log "$0" 2 "Cannot find AUTH_TOKEN env variable"
    exit
fi

if [ -z "${WATCH_FOLDER+x}" ]; then
    log "$0" 2 "Cannot find WATCH_FOLDER env variable"
    exit
fi

log "$0" 0 "Starting inotify"
inotifywait -r -m "${WATCH_FOLDER}" -e moved_to -e close_write  |
while read -r directory events filename; do
    if [ -n "${filename+x}" ] && [ ! "${filename}" = "" ]; then
        log "$0" 1 "Found new file | Filename: ${filename}"
        curl -H "Authorization: Token ${AUTH_TOKEN}"  \
            -T "${directory}${filename}"  \
            "${PAPERMERGE_HOST}/api/document/upload/${filename}" && \
                echo "" \
            || \
                log "$0" 2 "curl: error ${?}" \
        && \
            rm -f "${directory}${filename}" || \
                log "$0" 2 "rm file: error ${?}" \
        && \
            log "$0" 0 "------------------------------------------------------"
    fi
done
