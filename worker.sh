#!/usr/bin/with-contenv bash
# shellcheck shell=bash

upload() {
    local worker_dir="$1"
    local worker_file="$2"
    if [ -n "${worker_file+x}" ] && [ ! "${worker_file}" = "" ]; then
        log "$0" 1 "------------------------------------------------------"
        log "$0" 1 "Found new file | Filename: ${worker_file}"
        log "$0" 1 "curl -s -o /tmp/api_response -w \"%{http_code}\" -H \"Authorization: Token ${AUTH_TOKEN:0:3}...${AUTH_TOKEN: -3}\" -T \"${worker_dir}${worker_file}\" \"${PAPERMERGE_HOST}/api/document/upload/${worker_file}\""
        result_code=$(sendFile "${worker_dir}" "${worker_file}")
        case $result_code in
            200)
                resultOK "${worker_dir}" "${worker_file}"
            ;;
            *)
                resultKO "${result_code}"
            ;;
        esac
    fi
}

sendFile() {
    local send_dir="$1"
    local send_file="$2"
    send_code=$(curl -s -o /tmp/api_response -w "%{http_code}" \
                    -H "Authorization: Token ${AUTH_TOKEN}" \
                    -T "${send_dir}${send_file}" \
                    "${PAPERMERGE_HOST}/api/document/upload/${send_file}")
    echo "${send_code}"
}

resultOK() {
    local resultok_dir="$1"
    local resultok_file="$2"
    rm -f "${resultok_dir}${resultok_file}" \
    || \
        log "$0" 3 "rm file \"${resultok_dir}${resultok_file}\": error ${?}" \
    && \
        local ok_json; \
        ok_json=$(<"/tmp/api_response"); \
        log "$0" 0 "RESULT: ${ok_json}"; \
        log "$0" 0 "------------------- File uploaded --------------------"; \
        log "$0" 0 "------------------------------------------------------"
}

resultKO() {
    local resultko_code="$1"
    local error_json
    error_json=$(<"/tmp/api_response")
    log "$0" 3 "curl: error (${resultko_code}) ${error_json}"
    rm -f "/tmp/api_response" || \
        log "$0" 3 "rm file \"/tmp/api_response\": error ${?}"
        log "$0" 3 "----------------- File NOT uploaded ------------------"; \
        log "$0" 3 "------------------------------------------------------"
}
