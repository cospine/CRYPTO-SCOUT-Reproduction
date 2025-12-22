#!/usr/bin/env bash
if [ ! -z "${OPTION}" ]; then
    if [ ${OPTION} = "p"  ]; then
        path_crypto_scout_result="/crypto_scout/cache/crypto_scout.middle"
        mkdir -p /crypto_scout/cache/
        cd /crypto_scout/bin
        python2 crypto_scout.pyc -s ${BYTECODE_DIR}/${BYTECODE_FILE_NAME} -b | tee ${path_crypto_scout_result}
        python2 result_analyzer.pyc -p ${path_crypto_scout_result} | tee ${BYTECODE_DIR}/${BYTECODE_FILE_NAME}_result.json
    fi
fi