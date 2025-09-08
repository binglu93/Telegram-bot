#!/bin/bash
# Script: List user vmess
# Update ®2025
# Menampilkan daftar akun VMESS dari config.json dengan format elegan
# ==================================================================

BURIT_GANAL="/etc/xray/config.json"
export LANG=en_US.UTF-8

if [ ! -f "$BURIT_GANAL" ]; then
    echo -e "🚫 *File konfigurasi tidak ditemukan:* \`$BURIT_GANAL\`"
    exit 1
fi

NUMBER_OF_CLIENTS=$(grep -c -E "^#vmg " "$BURIT_GANAL")

if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "🚫 *Tidak ada akun VMESS yang aktif*"
else
    echo -e "🚀 *D A F T A R  A K U N  V M E S S*"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "〄  *USER*   *UUID*   *EXPIRED*"
    echo -e "―――――――――――――――――――――――――――――"

    # List user dari config.json
    grep -E "^#vmg " "$BURIT_GANAL" | nl -w1 -s ' ' | while read -r num line; do
        user=$(echo "$line" | awk '{print $2}')
        uuid=$(echo "$line" | awk '{print $4}')
        exp=$(echo "$line" | awk '{print $3}')
        printf "👤 %-15s %s\n" "$user" "$uuid" "$exp"
    done

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📊 *Total Akun*: *$NUMBER_OF_CLIENTS*"
fi

exit 0
