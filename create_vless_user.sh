#!/bin/bash

# ==================================================================
#       SKRIP C1 - TROJAN BY (JULAK BANTUR)
# ==================================================================

# Validasi argumen
if [ "$#" -ne 4 ]; then
    echo "❌ Error: Butuh 4 argumen: <user> <masa_aktif> <ip_limit> <kuota_gb>"
    exit 1
fi

# Ambil parameter
user="$1"; masaaktif="$2"; iplim="$3"; Quota="$4"

# Ambil variabel server
domain=$(cat /etc/xray/domain); ISP=$(cat /root/.isp); CITY=$(cat /root/.city)
uuid=$(cat /proc/sys/kernel/random/uuid); exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
CONFIG_FILE="/etc/xray/config.json"

# Cek user
if grep -q "\"$user\"" "$CONFIG_FILE"; then
    echo "❌ Error: Username '$user' sudah ada."
    exit 1
fi

# --- Simpan limit IP ---
echo "$iplim" > /etc/julak/limit/trojan/ip//${user}

# ==================================================================
#   Inti Perbaikan Final: Perintah 'sed' sekarang 100% identik.
# ==================================================================
# Tambahkan user ke Trojan WS
sed -i '/#trojanws$/a\#! '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' "$CONFIG_FILE"

# Tambahkan user ke Trojan gRPC
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' "$CONFIG_FILE"


# Atur variabel untuk output
if [ "$Quota" = "0" ]; then QuotaGb="Unlimited"; else QuotaGb="$Quota"; fi
if [ "$iplim" = "0" ]; then iplim_val="Unlimited"; else iplim_val="$iplim"; fi

# Buat link Trojan
trojanlink3="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${domain}#${user}"
trojanlink1="trojan://${uuid}@${domain}:443?path=%2Ftrojan-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojanlink2="trojan://${uuid}@${domain}:80?path=%2Ftrojan-ws&security=auto&host=${domain}&type=ws#${user}"

# Restart service xray
systemctl restart xray > /dev/null 2>&1

# Hasilkan output lengkap untuk Telegram dengan ikon dan format keren
TEXT="
🌟━━━━━━━━━━━━━━━━━━🌟
👑 Premium Trojan Account 👑
🌟━━━━━━━━━━━━━━━━━━🌟
👤 User        : ${user}
🌐 Domain      : ${domain}
🔒 Login Limit : ${iplim_val} IP
📊 Quota Limit : ${QuotaGb} GB
🔌 Port TLS    : 443
🔌 Port NTLS   : 80
🔌 Port GRPC   : 443
🔑 Password    : ${uuid}
🔗 Network     : WS or gRPC
➡️ Path WS     : /trojan-ws
➡️ ServiceName : trojan-grpc
🌟━━━━━━━━━━━━━━━━━━🌟
🔗 Link TLS    :
${trojanlink1}
🌟━━━━━━━━━━━━━━━━━━🌟
🔗 Link WS     :
${trojanlink2}
🌟━━━━━━━━━━━━━━━━━━🌟
🔗 Link GRPC   :
${trojanlink3}
🌟━━━━━━━━━━━━━━━━━━🌟
📅 Berakhir Pada : $exp
🌟━━━━━━━━━━━━━━━━━━🌟
TERIMAKASIH TELAH ORDER VPN DI JULAKSSH
"
echo "$TEXT"

# Membuat file log untuk user
LOG_FILE="/etc/xray/log-create-${user}.log"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e " XRAY TROJAN ACCOUNT          " >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "Username         : ${user}" >> "$LOG_FILE"
echo -e "Host             : ${domain}" >> "$LOG_FILE"
echo -e "Limit Ip         : ${iplim_val} Login" >> "$LOG_FILE"
echo -e "Limit Quota      : ${QuotaGb} GB" >> "$LOG_FILE"
echo -e "Port TLS & gRPC  : 443" >> "$LOG_FILE"
echo -e "Port None TLS    : 80" >> "$LOG_FILE"
echo -e "Id               : ${uuid}" >> "$LOG_FILE"
echo -e "Path             : /trojan-ws ~ (/Multipath)" >> "$LOG_FILE"
echo -e "ServiceName      : trojan-grpc" >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "Link WS          :" >> "$LOG_FILE"
echo -e "${trojanlink1}" >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "Link None TLS     :" >> "$LOG_FILE"
echo -e "${trojanlink2}" >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "Link GRPC        :" >> "$LOG_FILE"
echo -e "${trojanlink3}" >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "Berakhir Pada    : $exp" >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"
echo -e "        Script By Julak Bantur             " >> "$LOG_FILE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" >> "$LOG_FILE"

exit 0
