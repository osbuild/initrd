#!/usr/bin/bash

# Test that cgroup2 is properly mounted in the VM

ROOTFS=$1

if [ -z "$ROOTFS" ]; then
    echo "Usage: $0 <rootfs_path>"
    exit 1
fi

timeout --foreground --kill-after=10s 60s ./chrootvm --mount-ro test test "$ROOTFS" /run/mnt/test/init_cgroup2.sh | tee output_cgroup2.txt || exit_code=$?

if [ "${exit_code:-0}" -ne 0 ]; then
    if [ "${exit_code:-0}" -eq 124 ]; then
        echo "Cgroup2 test failed with timeout"
    else
        echo "Cgroup2 test failed with exit code ${exit_code}"
    fi
    cat output_cgroup2.txt
    exit 1
fi

if ! grep -q "Cgroup2 mount test PASSED" output_cgroup2.txt; then
    echo "Cgroup2 test failed: Test did not pass"
    cat output_cgroup2.txt
    exit 1
fi

echo "Cgroup2 mount test passed"
exit 0
