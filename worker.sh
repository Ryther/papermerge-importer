#!/usr/bin/with-contenv bash
# shellcheck shell=bash

upload() {
    local worker_dir="$1"
    local worker_file="$2"
    if [ -n "${worker_file+x}" ] && [ ! "${worker_file}" = "" ]; then
        log "$0" 1 "Found new file | Filename: ${worker_file}"
        result_code=$(sendFile "${worker_dir}" "${worker_file}")
        case $result_code in
            200)
                resultOK worker_dir worker_file
            ;;
            *)
                resultKO result_code
            ;;
        esac
    fi
}

sendFile() {
    local send_dir="$1"
    local send_file="$2"
    log "$0" 1 "curl -s -o /tmp/api_response -w \"%{http_code}\" -H \"Authorization: Token ${AUTH_TOKEN:0:3}...${AUTH_TOKEN: -3}\" -T \"${worker_directory}${filename}\" \"${PAPERMERGE_HOST}/api/document/upload/${filename}\""
    echo $(curl -s -o /tmp/api_response -w "%{http_code}" \
                    -H "Authorization: Token ${AUTH_TOKEN}" \
                    -T "${send_dir}${send_file}" \
                    "${PAPERMERGE_HOST}/api/document/upload/${send_file}")
}

resultOK() {
    local resultok_dir="$1"
    local resultok_file="$2"
    rm -f "${result_dir}${result_file}" \
    || \
        log "$0" 3 "rm file \"${result_dir}${result_file}\": error ${?}" \
    && \
        log "$0" 0 "------------------- File uploaded --------------------"
        log "$0" 0 "------------------------------------------------------"
}

resultKO() {
    local resultko_code="$1"
    error_msg=$(<"/tmp/api_response")
    log "$0" 3 "curl: error (${resultko_code}) ${error_msg}"
    rm -f "/tmp/api_response" || \
        log "$0" 3 "rm file \"/tmp/api_response\": error ${?}" \
}
