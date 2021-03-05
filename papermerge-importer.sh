#!/usr/bin/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source ./utils.sh
source ./worker.sh

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
    upload "${directory}" "${filename}"
done
