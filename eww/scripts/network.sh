#!/usr/bin/env bash

iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')

if [[ -z "$iface" ]]; then
    echo "0 B/s"
    exit 0
fi

r1=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
t1=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null || echo 0)
sleep 1
r2=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null || echo 0)
t2=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null || echo 0)

rx=$(( (r2 - r1) ))
tx=$(( (t2 - t1) ))

human_readable() {
    local bytes=$1
    if (( bytes >= 1048576 )); then
        echo "$(( bytes / 1048576 )) MB/s"
    elif (( bytes >= 1024 )); then
        echo "$(( bytes / 1024 )) KB/s"
    else
        echo "${bytes} B/s"
    fi
}

case "$1" in
    down) human_readable "$rx" ;;
    up)   human_readable "$tx" ;;
    *)    echo "Usage: $0 {down|up}" ;;
esac
