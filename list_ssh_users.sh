#!/bin/bash
# ==================================================================
# Menampilkan daftar akun SSH aktif dengan format elegan untuk Telegram
#             (Adapted from user's del-vmess function)
# ==================================================================

CAWAT_LANDU="/etc/ssh/.ssh.db"
export LANG=en_US.UTF-8

if [ ! -f "$CAWAT_LANDU" ]; then
    echo -e "🚫 *File konfigurasi tidak ditemukan!*"
    exit 1
fi

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CAWAT_LANDU")

if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "🚫 *Tidak ada akun SSH yang aktif*"
else
    echo -e "✨ *D A F T A R  A K U N  S S H* ✨"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "〄  *USER*   *PASS*  *EXPIRED*"
    echo -e "―――――――――――――――――――――――――――――"

    # Loop daftar user dari file config
    grep -E "^### " "$CAWAT_LANDU" | while read -r line; do
        user=$(echo "$line" | awk '{print $2}')
        pass=$(echo "$line" | awk '{print $3}')
        exp=$(echo "$line" | awk '{print $4}')
        printf "👤 %-15s %s\n" "$user" "$uuid" "$exp"
    done

    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📊 *Total Akun*: *$NUMBER_OF_CLIENTS*"
fi
