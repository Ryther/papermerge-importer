#!/usr/bin/with-contenv bash
# shellcheck shell=bash

if [ -z "${PAPERMERGE_HOST+x}" ]; then
    echo "[papermerge-importer.sh] Cannot find PAPERMERGE_HOST env variable"
    exit
fi

if [ -z "${AUTH_TOKEN+x}" ]; then
    echo "[papermerge-importer.sh] Cannot find AUTH_TOKEN env variable"
    exit
fi

if [ -z "${WATCH_FOLDER+x}" ]; then
    echo "[papermerge-importer.sh] Cannot find WATCH_FOLDER env variable"
    exit
fi

inotifywait -r -m "${WATCH_FOLDER}" -e moved_to -e close_write  |
while read -r directory events filename; do
    if [ -n "${filename+x}" ] && [ ! "${filename}" = "" ]; then
        echo "[papermerge-importer.sh] ------------------------------------------------------"
        echo "[papermerge-importer.sh] Found new file: |${filename}|"
        curl -H "Authorization: Token ${AUTH_TOKEN}"  \
            -T "${directory}${filename}"  \
            "${PAPERMERGE_HOST}/api/document/upload/${filename}" && \
                echo "" \
            || \
                echo "[papermerge-importer.sh] curl: error ${?}" \
        && \
        rm -f "${directory}${filename}" || \
                echo "[papermerge-importer.sh] rm file: error ${?}"
        echo "[papermerge-importer.sh] ------------------------------------------------------"
    fi
done
