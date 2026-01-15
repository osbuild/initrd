#!/usr/bin/bash

ROOTFS=$1

timeout --foreground --kill-after=10s  60s ./chrootvm --mount-ro test test $ROOTFS /run/mnt/test/init.sh | tee output.txt || exit_code=$?

if [ "${exit_code:-0}" -ne 0 ]; then
    if [ "${exit_code:-0}" -eq 124 ]; then
        echo "VM boot test failed with timeout"
    else
        echo "VM boot test failed with exit code ${exit_code}"
    fi
    exit 1
fi

if ! grep -q "This is init.sh talking" output.txt ; then
    echo "VM boot test failed: Unexpected content in output:"
    exit 1
fi

echo "VM boot test passed"
exit 0
