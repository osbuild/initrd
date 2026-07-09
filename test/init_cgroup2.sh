#!/usr/bin/bash

echo "=== Cgroup2 mount test ==="

# Check if /sys/fs/cgroup is mounted
if mountpoint -q /sys/fs/cgroup; then
    echo "PASS: /sys/fs/cgroup is mounted"
else
    echo "FAIL: /sys/fs/cgroup is not mounted"
    exit 1
fi

# Check if it's cgroup2 (unified hierarchy)
if grep -q "cgroup2" /proc/mounts | grep -q "/sys/fs/cgroup"; then
    echo "PASS: /sys/fs/cgroup is cgroup2"
elif [ -f /sys/fs/cgroup/cgroup.controllers ]; then
    echo "PASS: /sys/fs/cgroup is cgroup2 (verified via cgroup.controllers)"
else
    echo "FAIL: /sys/fs/cgroup is not cgroup2"
    cat /proc/mounts | grep cgroup
    exit 1
fi

echo "=== Cgroup2 mount test PASSED ==="

# Trigger shutdown
echo o > /proc/sysrq-trigger
sleep 100
