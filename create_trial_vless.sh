#!/bin/bash
# ==================================================================
#       SKRIP C1 - CREATE VLESS TRIAL (Metode 'sed' seperti VMESS)
# ==================================================================

# --- Parameter Trial (Diatur di sini) ---
masaaktif="1"      # Durasi trial dalam hari
iplim="1"          # Limit IP untuk trial
quota="0"          # Kuota dalam GB (0 = Unlimited)
# Generate username trial yang unik
user="trial-$(tr -dc A-Z0-9 </dev/urandom | head -c 5)"

# --- Variabel & Persiapan Data ---
CONFIG_FILE="/etc/xray/config.json"
domain=$(cat /etc/xray/domain)
uuid=$(cat /proc/sys/kernel/random/uuid)
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# Cek duplikasi user (kemungkinan kecil terjadi, tapi tetap baik untuk ada)
if grep -q "\"$user\"" "$CONFIG_FILE"; then
    echo "❌ Error: Username trial '$user' kebetulan sudah ada. Coba lagi."
    exit 1
fi

# ==================================================================
#         INTI PERUBAHAN: Menggunakan 'sed' seperti skrip Premium
# ==================================================================
# CATATAN PENTING:
# Pastikan penanda #vlessws dan #vlessgrpc ada di dalam file config.json Anda.
# Tanpa penanda ini, skrip TIDAK akan berfungsi.

# Tambahkan user ke VLESS WS
sed -i '/#vless$/a\#& '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json

# --- Hasilkan Output ---
# Atur variabel untuk tampilan
[ "$iplim" = "0" ] && iplim_display="∞ Unlimited" || iplim_display="$iplim"
[ "$quota" = "0" ] && quota_display="∞ Unlimited" || quota_display="${quota} GB"

# Buat link Vless
vlesslink1="vless://${uuid}@${domain}:443?path=/vless&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vless&security=none&encryption=none&host=${domain}&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${domain}#${user}"

# Restart service xray dengan senyap
systemctl restart xray > /dev/null 2>&1

# Format output yang indah untuk Telegram
TEXT="
═══════[ VLESS TRIAL ]═══════
🆔 Username: $user
🌐 Domain: $domain
⏳ Expired: $exp
═══════════════════════════════
📡 Server Info:
🔒 Security:
├─ 🔑 UUID: $uuid
└─ 🛡️ Encryption: none
📊 Limits:
├─ 🖥️ IP Limit: $iplim_display
└─ 📶 Quota: $quota_display
═══════════════════════════════
🔗 Connection Links:
┌─ 🌐 TLS (443):
│  ${vlesslink1}
│
├─ 🌍 NTLS (80):
│  ${vlesslink2}
│
└─ 🚀 gRPC (443):
   ${vlesslink3}
═══════════════════════════════
⚠️ Akun trial hanya untuk tes!
"

# Simpan log ke file
echo "$TEXT" > "/etc/xray/log-create-${user}.log"

# Tampilkan output ke stdout
echo "$TEXT"

exit 0
