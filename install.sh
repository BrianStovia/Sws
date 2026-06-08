#!/usr/bin/env bash
# ========================================================
# Credit Code By FN Project
# Author: Rerechan02 (DindaPutriFN)
# License: This configuration is licensed for personal or internal use only.
#          Redistribution, resale, or reuse of this code in any form
#          without explicit written permission from the author is prohibited.
#          Selling this code or its derivatives is strictly forbidden.
# ========================================================

# Clear SUDO_USER to bypass acme.sh warnings under sudo
export SUDO_USER=""

# Define Colors
green="\e[1;32m"
NC="\e[0m"

# Define Hosting
hosting="https://raw.githubusercontent.com/BrianStovia/Sws/main"

# Get directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to get file from local workspace
get_file() {
    local source_name="$1"
    local dest_path="$2"
    
    if [ -f "${SCRIPT_DIR}/${source_name}" ]; then
        echo "Using local file ${source_name}..."
        cp "${SCRIPT_DIR}/${source_name}" "${dest_path}"
    elif [ -f "${SCRIPT_DIR}/file/${source_name}" ]; then
        echo "Using repository file file/${source_name}..."
        cp "${SCRIPT_DIR}/file/${source_name}" "${dest_path}"
    else
        echo "Downloading ${source_name} from hosting..."
        wget -q -O "${dest_path}" "${hosting}/${source_name}"
        if [ $? -ne 0 ]; then
            echo "Downloading ${source_name} from hosting/file..."
            wget -q -O "${dest_path}" "${hosting}/file/${source_name}"
            if [ $? -ne 0 ]; then
                echo "Error: Failed to download ${source_name} from hosting!"
                exit 1
            fi
        fi
    fi
}

if [ -f "/usr/local/etc/v2ray/domain" ]; then
echo "Script Already Installed"
exit 1
fi

if [ -f "/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 1
fi

if [ -f "/etc/v2ray/domain" ]; then
echo "Script Already Installed"
exit 1
fi

if [ -f "/root/domain" ]; then
echo "Script Already Installed"
exit 1
fi

clear
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "$green          Input Domain              	$NC"
echo -e "\e[33m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
if [ -z "$domain" ]; then
    read -p " Input Your SubDomain : " domain
fi

clear

# Resolv
echo -e "nameserver 1.1.1.1" >> /etc/resolv.conf

# Memperbaiki Port Default Login SSH & Optimasi Speed SSH
cd /etc/ssh
find . -type f -name "*sshd_config*" -exec sed -i 's|#Port 22|Port 22|g' {} +
echo -e "Port 3303" >> sshd_config
echo -e "Port 109" >> sshd_config

# SSH Speed Optimization Configurations
sed -i '/^UseDNS/d' sshd_config 2>/dev/null
sed -i '/^GSSAPIAuthentication/d' sshd_config 2>/dev/null
sed -i '/^Ciphers/d' sshd_config 2>/dev/null
sed -i '/^MACs/d' sshd_config 2>/dev/null

echo -e "UseDNS no" >> sshd_config
echo -e "GSSAPIAuthentication no" >> sshd_config
echo -e "Ciphers aes128-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-gcm@openssh.com" >> sshd_config
echo -e "MACs hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512-etm@openssh.com" >> sshd_config
cd
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd

# Network & TCP Speed Optimization (BBR)
sysctl_optimize() {
    local key="$1"
    local val="$2"
    sed -i "/^${key}/d" /etc/sysctl.conf 2>/dev/null
    echo "${key} = ${val}" >> /etc/sysctl.conf
}

echo "Optimizing network and TCP settings..."
sysctl_optimize "fs.file-max" "2097152"
sysctl_optimize "net.core.default_qdisc" "fq"
sysctl_optimize "net.ipv4.tcp_congestion_control" "bbr"
sysctl_optimize "net.core.rmem_max" "67108864"
sysctl_optimize "net.core.wmem_max" "67108864"
sysctl_optimize "net.core.rmem_default" "33554432"
sysctl_optimize "net.core.wmem_default" "33554432"
sysctl_optimize "net.core.optmem_max" "2048576"
sysctl_optimize "net.ipv4.tcp_rmem" "4096 87380 67108864"
sysctl_optimize "net.ipv4.tcp_wmem" "4096 65536 67108864"
sysctl_optimize "net.ipv4.tcp_fastopen" "3"
sysctl_optimize "net.ipv4.tcp_fin_timeout" "15"
sysctl_optimize "net.ipv4.tcp_keepalive_time" "300"
sysctl_optimize "net.ipv4.tcp_keepalive_probes" "5"
sysctl_optimize "net.ipv4.tcp_keepalive_intvl" "15"
sysctl_optimize "net.ipv4.tcp_max_syn_backlog" "8192"
sysctl_optimize "net.ipv4.tcp_max_tw_buckets" "1440000"
sysctl_optimize "net.ipv4.tcp_tw_reuse" "1"
sysctl -p

# System Limits Optimization
if ! grep -q "* soft nofile" /etc/security/limits.conf; then
cat >> /etc/security/limits.conf <<EOF
* soft nofile 1000000
* hard nofile 1000000
root soft nofile 1000000
root hard nofile 1000000
EOF
fi

# Non Interactive
export DEBIAN_FRONTEND=noninteractive
apt update

# Pakcage
apt install curl wget gnupg openssl -y
apt install jq -y
apt install perl -y
apt install sudo -y
apt install screen -y
apt install socat -y
apt install util-linux -y
apt install lsb-release -y
apt install bsdextrautils -y 2>/dev/null || apt install bsdmainutils -y
apt install iptables -y
apt install iptables-persistent -y
apt install binutils -y
apt install python3 python3-pip -y
apt install zip -y
apt install unzip -y
apt install bc -y

# Setup Banner SSH
sed -i '/^#\?Banner /c\Banner /etc/issue.net' /etc/ssh/sshd_config
rm -f /etc/issue.net
get_file "issue.net" "/etc/issue.net"
chmod +x /etc/issue.net
systemctl daemon-reload
systemctl restart ssh
systemctl restart sshd

# Installasi Dropbear
apt install dropbear -y
rm /etc/default/dropbear
clear
# RSA
rm -f /etc/dropbear/dropbear_rsa_host_key
dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key

# DSS (DSA)
rm -f /etc/dropbear/dropbear_dss_host_key
dropbearkey -t dss -f /etc/dropbear/dropbear_dss_host_key

# ECDSA
rm -f /etc/dropbear/dropbear_ecdsa_host_key
dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key
cat>  /etc/default/dropbear << END
# All configuration by FN Project / Rerechan02
# Dinda Putri Cindyani
# disabled because OpenSSH is installed
# change to NO_START=0 to enable Dropbear
NO_START=0
# the TCP port that Dropbear listens on
DROPBEAR_PORT=111

# any additional arguments for Dropbear
#DROPBEAR_EXTRA_ARGS="-p 109 -p 69 "

# specify an optional banner file containing a message to be
# sent to clients before they connect, such as "/etc/issue.net"
DROPBEAR_BANNER="/etc/issue.net"

# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"

# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)
#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"

# ECDSA hostkey file (default: /etc/dropbear/dropbear_ecdsa_host_key)
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"

# Receive window size - this is a tradeoff between memory and
# network performance
DROPBEAR_RECEIVE_WINDOW=65536
END
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
systemctl daemon-reload
systemctl enable dropbear
systemctl restart dropbear
clear

# Save Data IP
curl -s http://checkip.amazonaws.com > /root/.ip

# Special SSLH
echo 'sslh   sslh/inetd_or_standalone select standalone' | sudo debconf-set-selections
apt update -y
apt install sslh -y

# Main Menu
mkdir -p /usr/local/sbin
cd /usr/local/sbin
get_file "main.zip" "m.zip"
unzip -o m.zip
chmod +x *
rm -f m.zip

# Symlink all custom sbin scripts to /usr/bin to ensure they are always in PATH
for file in /usr/local/sbin/*; do
    if [ -f "$file" ]; then
        ln -sf "$file" "/usr/bin/$(basename "$file")"
    fi
done

# Ensure /usr/local/sbin is in PATH for all profiles
if ! grep -q "PATH.*usr/local/sbin" /etc/profile 2>/dev/null; then
    echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"' >> /etc/profile
fi
if [ -f "/root/.profile" ] && ! grep -q "PATH.*usr/local/sbin" /root/.profile 2>/dev/null; then
    echo 'export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"' >> /root/.profile
fi

# Stoping HTTP
systemctl stop apache2
systemctl disable apache2

# Setup SSLH
cd /etc/default
rm -f sslh
get_file "sslh" "sslh"
chmod 755 sslh
cd

# Setup Rest Api
mkdir -p /usr/local/sbin/api
cd /usr/local/sbin/api
chmod +x *
cd
get_file "server" "/usr/bin/server"
chmod +x /usr/bin/server
cat> /etc/systemd/system/server.service << END
[Unit]
Description=WebAPI Server Proxy All OS By rbstv
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/bin/server
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END
mkdir -p /etc/api

# Setup Proxy SSHWS
cd /usr/local/bin
get_file "proxy" "proxy"
chmod +x proxy
cd
echo -e "[Unit]
Description=WebSocket
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/proxy
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/proxy.service

# Setup Socks5 Proxy
if apt install dante-server -y 2>/dev/null; then
    sudo touch /var/log/danted.log
    sudo chown root:root /var/log/danted.log
    primary_interface=$(ip route | grep default | awk '{print $5}')
    sudo bash -c "cat <<EOF > /etc/danted.conf
logoutput: /var/log/danted.log
internal: 0.0.0.0 port = 1080
external: $primary_interface
method: username
user.privileged: root
client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}
EOF"
    if [ -f "/usr/lib/systemd/system/danted.service" ]; then
        sudo sed -i '/\[Service\]/a ReadWriteDirectories=/var/log' /usr/lib/systemd/system/danted.service
    elif [ -f "/lib/systemd/system/danted.service" ]; then
        sudo sed -i '/\[Service\]/a ReadWriteDirectories=/var/log' /lib/systemd/system/danted.service
    fi
    sudo systemctl daemon-reload
    sudo systemctl restart danted
    sudo systemctl enable danted
else
    echo "dante-server not available. Installing microsocks SOCKS5 proxy instead..."
    if apt install microsocks -y 2>/dev/null; then
        cat <<EOF > /etc/systemd/system/microsocks.service
[Unit]
Description=MicroSocks SOCKS5 Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/microsocks -p 1080
Restart=always

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable microsocks
        systemctl start microsocks
    else
        echo "Warning: Both dante-server and microsocks SOCKS5 proxies failed to install."
    fi
fi

# Setup Nginx
apt install nginx -y
rm -f /etc/nginx/nginx.conf
get_file "nginx.conf" "/etc/nginx/nginx.conf"
sed -i "s|server_name fn.com;|server_name $domain;|" /etc/nginx/nginx.conf
systemctl stop nginx
systemctl disable nginx

# Setup Badvpn
wget -O /usr/local/bin/badvpn "https://raw.githubusercontent.com/powermx/badvpn/master/badvpn-udpgw" &>/dev/null
chmod +x /usr/local/bin/badvpn
echo -e "[Unit]
Description=BadVPN Gaming Support Port 7300 By rbstv
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/local/bin/badvpn --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 1000 --client-socket-sndbuf 0 --udp-mtu 9000
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/badvpn.service
systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn
systemctl restart badvpn

# Setup UDP Custom
rm -rf /etc/udp
mkdir -p /etc/udp
echo downloading udp-custom
get_file "udp-custom-linux-amd64" "/etc/udp/udp-custom"
chmod +x /etc/udp/udp-custom
echo downloading default config
get_file "udp.json" "/etc/udp/config.json"
chmod 644 /etc/udp/config.json
cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team and modify by FN Project

[Service]
User=root
Type=simple
ExecStart=/etc/udp/udp-custom server -exclude 7300
WorkingDirectory=/etc/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=default.target
EOF
echo start service udp-custom
systemctl start udp-custom &>/dev/null
echo enable service udp-custom
systemctl enable udp-custom &>/dev/null

# Cron
apt install cron -y
echo -e "
*/15 * * * * root echo -n > /var/log/v2ray/access.log
*/15 * * * * root xp
" >> /etc/crontab
systemctl daemon-reload
systemctl restart cron

# ===== Setup V2ray ======
# Check if the group 'nobody' exists
if getent group nobody > /dev/null; then
    echo "Group 'nobody' already exists."
else
    echo "Group 'nobody' does not exist. Creating..."
    groupadd nobody
fi

# Check if the user 'nobody' exists
if getent passwd nobody > /dev/null; then
    echo "User 'nobody' already exists."
else
    echo "User 'nobody' does not exist. Creating..."
    useradd -g nobody -M -s /sbin/nologin nobody
fi

# Ensure V2Ray configuration directory exists
mkdir -p /usr/local/etc/v2ray

# Install V2Ray with retries
echo "Installing V2Ray..."
for i in {1..3}; do
    if bash <(curl -L https://raw.githubusercontent.com/v2fly/fhs-install-v2ray/master/install-release.sh); then
        echo "V2Ray installed successfully!"
        break
    else
        echo "V2Ray installation failed, retrying ($i/3)..."
        sleep 3
    fi
done

rm -f /usr/local/etc/v2ray/config.json
get_file "config.json" "/usr/local/etc/v2ray/config.json"

# Setup NoobzVPNS
clear
mkdir -p /etc/noobzvpns
cd /etc/noobzvpns
rm -fr *
get_file "config.toml" "config.toml"
wget -q -O /usr/bin/noobzvpns "https://github.com/noobz-id/noobzvpns/raw/master/noobzvpns.x86-64"
chmod +x /usr/bin/noobzvpns
echo -e "[Unit]
Description=NoobzVpn-Server
Wants=network-online.target
After=network.target network-online.target

[Service]
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
User=root
Type=simple
TimeoutStopSec=1
LimitNOFILE=infinity
ExecStart=/usr/bin/noobzvpns start-server

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/noobzvpns.service
chmod +x /etc/noobzvpns/*
cd

# Certificate
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2080 2>/dev/null || true
echo -e "${domain}" > /usr/local/etc/v2ray/domain
    rm -rf /root/.acme.sh
    mkdir -p /root/.acme.sh
    curl -sSL https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o /root/.acme.sh/acme.sh
    chmod +x /root/.acme.sh/acme.sh
    /root/.acme.sh/acme.sh --upgrade --auto-upgrade || true
    # SSL Certificate Generation with Fallback (LetsEncrypt -> ZeroSSL -> BuyPass)
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    if ! /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256; then
        echo "Let's Encrypt rate-limited or failed. Trying ZeroSSL..."
        /root/.acme.sh/acme.sh --register-account -m admin@${domain} --server zerossl
        /root/.acme.sh/acme.sh --set-default-ca --server zerossl
        if ! /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256; then
            echo "ZeroSSL failed. Trying BuyPass..."
            /root/.acme.sh/acme.sh --set-default-ca --server buypass
            /root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
        fi
    fi
    /root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/v2ray/v2ray.crt --keypath /usr/local/etc/v2ray/v2ray.key --ecc

cd /root

# Service NoobzVPN
systemctl daemon-reload
systemctl enable noobzvpns
systemctl start noobzvpns

# Enable & Start Service
systemctl daemon-reload
pkill sslh
systemctl enable v2ray
systemctl enable nginx
systemctl enable sslh
systemctl restart v2ray
systemctl restart nginx
systemctl restart sslh
systemctl enable proxy
systemctl start proxy
systemctl restart proxy

# Setup Stunnel4
echo "Installing and configuring Stunnel4..."
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf << END
pid = /var/run/stunnel4.pid
cert = /usr/local/etc/v2ray/v2ray.crt
key = /usr/local/etc/v2ray/v2ray.key

[dropbear_222]
accept = 0.0.0.0:222
connect = 127.0.0.1:111

[dropbear_777]
accept = 0.0.0.0:777
connect = 127.0.0.1:111

[openssh_990]
accept = 0.0.0.0:990
connect = 127.0.0.1:22
END
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
systemctl daemon-reload
systemctl enable stunnel4
systemctl restart stunnel4


# ===== IP Tables Main Port

# Redirect TCP 443 ke TCP 2443
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 2443

# Redirect UDP 443 ke UDP 36712
iptables -t nat -A PREROUTING -p udp --dport 443 -j REDIRECT --to-port 36712

# Redirect TCP 80 ke TCP 2080
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2080

# Redirect UDP 80 ke UDP 26712
iptables -t nat -A PREROUTING -p udp --dport 80 -j REDIRECT --to-port 36712

iptables-save > /etc/iptables/rules.v4

clear
# rm -f /root/* # Disabled to protect local files and workspace from accidental deletion

echo -e "menu" >> /root/.profile
clear
echo -e "Success Install"
exit 0
