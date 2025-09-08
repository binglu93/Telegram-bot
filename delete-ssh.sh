#!/bin/bash

# =================================================================
#           Skrip Penghapusan Akun SSH untuk Julak-BOT
# =================================================================
# Deskripsi: Skrip ini menghapus user SSH dari sistem dan
#            file info terkait.
# =================================================================

# --- Validasi Input ---
if [ "$#" -ne 1 ]; then
    echo "<b>Error:</b> Nama pengguna tidak diberikan."
    echo "Penggunaan: $0 <username>"
    exit 1
fi

USERNAME=$1
FILE_INFO="/var/www/html/ssh-${USERNAME}.txt"
FILE_LOG="/etc/xray/log-createssh-${USERNAME}.log"
FILE_LIMIT="/etc/julak/limit/ssh/ip//${USERNAME}"

# --- Validasi User ---
# Periksa apakah user benar-benar ada sebelum mencoba menghapus
if ! id "$USERNAME" &>/dev/null; then
    echo "<b>Peringatan:</b> User <code>$USERNAME</code> tidak ditemukan di sistem."
    exit 1
fi

# --- Proses Penghapusan ---
# Hapus user dan direktori home-nya (-r flag)
userdel -r "$USERNAME" &>/dev/null
exp=$(grep -w "^### $user" "/etc/ssh/.ssh.db" | cut -d ' ' -f 3 | sort | uniq)
echo "/^### $user $exp /,/^},{/d" /etc/ssh/.ssh.db

# Hapus Log create user Jika ada
if [ -f "$FILE_LOG" ]; then
    rm -f "$FILE_LOG"
fi

# Hapus file info di web server jika ada
if [ -f "$FILE_INFO" ]; then
    rm -f "$FILE_INFO"
fi

# Hapus Limit Ip user jika ada
if [ -f "$FILE_LIMIT" ]; then
    rm -f "$FILE_LIMIT"
fi

# --- Menampilkan Output Konfirmasi untuk Bot Telegram ---
cat << EOF
✅ <b>Berhasil Dihapus</b>

Akun SSH dengan detail berikut telah dihapus secara permanen dari server:

<b>Username:</b> <code>$USERNAME</code>

Semua data dan file terkait telah dibersihkan.
EOF

exit 0
