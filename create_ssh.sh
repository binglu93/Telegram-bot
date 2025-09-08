#!/bin/bash

# =================================================================
#           Skrip Pembuatan Akun SSH untuk Julak-BOT
#           Versi Final: Diperbaiki & Disederhanakan
# =================================================================

# --- Validasi Input ---
if [ "$#" -ne 4 ]; then
    echo "Error: Input tidak lengkap."
    echo "Penggunaan: $0 <username> <password> <durasi_hari> <limit_ip>"
    exit 1
fi

# --- Inisialisasi Variabel ---
USERNAME=$1
PASSWORD=$2
DURATION=$3
IP_LIMIT=$4
EXPIRED_DATE=$(date -d "+$DURATION days" +"%b %d, %Y")
EXPIRED_UNIX=$(date -d "+$DURATION days" +"%Y-%m-%d")

# --- Membuat User di Sistem dengan Penanganan Error ---
if id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' sudah ada."
    exit 1
fi

useradd -e "$EXPIRED_UNIX" -s /bin/false -M "$USERNAME"
if [ $? -ne 0 ]; then
    echo "Error: Gagal membuat user '$USERNAME'."
    exit 1
fi
echo -e "$PASSWORD\n$PASSWORD\n" | passwd "$USERNAME" &> /dev/null

# --- Simpan limit IP ---
echo "$IP_LIMIT" > /etc/julak/limit/ssh/ip//${USERNAME}

# --- Mengambil Informasi Server ---
domain=$(cat /etc/xray/domain 2>/dev/null || echo "not_set")
ISP=$(cat /root/.isp 2>/dev/null || echo "Unknown")
CITY=$(cat /root/.city 2>/dev/null || echo "Unknown")

# --- Membuat File .txt di Web Server ---
cat > /var/www/html/ssh-${USERNAME}.txt <<-END
---------------------------------------------------
Julak Bantur Autoscript 
---------------------------------------------------

Format SSH OVPN Account
---------------------
Username         : $USERNAME
Password         : $PASSWORD
Expired          : $EXPIRED_DATE
---------------------
Host             : $domain
Port OpenSSH     : 443, 80, 22
Port UdpSSH      : 1-65535,1-7200,1-7300,1-10000
Port Dropbear    : 443, 109
Port Dropbear WS : 443, 109
Port SSH WS      : 80,8080
Port SSH SSL WS  : 443
Port SSL/TLS     : 443
Port OVPN WS SSL : 443
Port OVPN SSL    : 443
Port OVPN TCP    : 443, 1194
Port OVPN UDP    : 2200
BadVPN UDP       : 7100, 7300, 7300
---------------------
Ssh Udp Custom : $domain:1-65535@$USERNAME:$PASSWORD
---------------------
Payload WSS: GET wss://[host]/ HTTP/1.1[crlf]Host: bug.com[crlf]Upgrade: websocket[crlf][crlf] 
---------------------
Remote Proxy : bug.com:8080
---------------------
@Premium_Script
---------------------
END

# =======================================================
# PENAMBAHAN FITUR: Simpan data user ke /etc/ssh/.ssh.db
# =======================================================
echo "### $USERNAME $PASSWORD $EXPIRED_DATE" >> /etc/ssh/.ssh.db
# =======================================================

# --- Membuat log file ---
cat > /etc/xray/log-createssh-${USERNAME}.log <<-END

echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e " SSH OVPN Account    "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Username         : $USERNAME"
echo -e "Password         : $PASSWORD" 
echo -e "Masa Aktif       : $EXPIRED_DATE"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Host             : $domain"
echo -e "Limit Ip         : ${IP_LIMIT} Login"
echo -e "Port OpenSSH     : 443,80,22"
echo -e "Port SSH UDP     : 1-65535,1-7200,1-7300,1-10000"
echo -e "Port Dropbear    : 443, 109 ,143"
echo -e "Port SSH WS      : 80,8080"
echo -e "Port SSH SSL WS  : 443"
echo -e "Port SSL/TLS     : 443"
echo -e "Port OVPN SSL    : 443"
echo -e "Port OVPN TCP    : 443, 1194"
echo -e "Port OVPN UDP    : 2200"
echo -e "BadVPN UDP       : 7100, 7200, 7300"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "SSH UDP Custom   : $domain:1-65535@$USERNAME:$PASSWORD"
echo -e "Link OVPN SSL    : http://$domain:81/ssl.ovpn"
echo -e "Link OVPN TCP    : http://$domain:81/tcp.ovpn"
echo -e "Link OVPN UDP    : http://$domain:81/udp.ovpn"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Payload Ws       : GET ws://[host]/ HTTP/1.1[crlf]Host: bug.com[crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: websocket[crlf][crlf]" 
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Save Link Account: https://$domain:81/ssh-$USERNAME.txt"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "        Script By Julak Bantur             "
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

END

# --- Menampilkan Output Lengkap untuk Bot Telegram (Dipercantik) ---
cat << EOF
🎊 SSH Premium Account Created 🎊
━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Account Info
  ┣ Username   : ${USERNAME}
  ┣ Password   : ${PASSWORD}
  ┣ Host       : ${domain}
  ┗ Expired On : ${EXPIRED_DATE}
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔌 Connection Info
  ┣ Limit      : ${IP_LIMIT} Device(s)
  ┣ OpenSSH    : 22
  ┣ Dropbear   : 109, 143
  ┣ Udp Custom : 1-65535
  ┣ SSL/TLS    : 443
  ┣ SSH WS     : 80, 8080
  ┣ SSH SSL WS : 443
  ┗ UDPGW      : 7100-7300
━━━━━━━━━━━━━━━━━━━━━━━━━━
🔗 Links & Payloads
  ┣ OVPN TCP : http://${domain}:81/tcp.ovpn
  ┣ OVPN UDP : http://${domain}:81/udp.ovpn
  ┗ OVPN SSL : http://${domain}:81/ssl.ovpn
  
  📋 Payload WS/WSS:
  GET / HTTP/1.1[crlf]Host: ${domain}[crlf]Upgrade: websocket[crlf]Connection: upgrade[crlf][crlf]
━━━━━━━━━━━━━━━━━━━━━━━━━━
💾 Save Full Config:
https://${domain}:81/ssh-${USERNAME}.txt
━━━━━━━━━━━━━━━━━━━━━━━━━━
🙏 Terima kasih telah order di Julak SSH
EOF

# Mengakhiri skrip dengan status sukses
exit 0
