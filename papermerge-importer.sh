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
        log "$0" 1 "curl -s -o /tmp/api_response -w \"%{http_code}\" -H \"Authorization: Token ${AUTH_TOKEN:0:3}...${AUTH_TOKEN: -3}\" -T \"${directory}${filename}\" \"${PAPERMERGE_HOST}/api/document/upload/${filename}\""
        httpCode=$(curl -s -o /tmp/api_response -w "%{http_code}" \
                    -H "Authorization: Token ${AUTH_TOKEN}" \
                    -T "${directory}${filename}" \
                    "${PAPERMERGE_HOST}/api/document/upload/${filename}")
        case $httpCode in
            200)
                rm -f "${directory}${filename}" \
                || \
                    log "$0" 3 "rm file \"${directory}${filename}\": error ${?}" \
                && \
                    log "$0" 0 "------------------------------------------------------"
            ;;
            *)
                error_msg=$(<"/tmp/api_response")
                log "$0" 3 "curl: error (${httpCode}) ${error_msg}"
                rm -f "/tmp/api_response" || \
                    log "$0" 3 "rm file \"/tmp/api_response\": error ${?}" \
            ;;
        esac
    fi
done
