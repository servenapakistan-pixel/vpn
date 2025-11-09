#!/bin/bash

# Запускаем tailscaled
tailscaled --tun=userspace-networking --socket=/var/run/tailscale/tailscaled.sock &
sleep 5

# Подключаемся к Tailscale с вашим auth key
tailscale up --authkey=tskey-auth-kMn6VAwJPU11CNTRL-VLRNbXs1avfyzGiyeUBHvfdpeZwKAz19b --hostname=render-ssh-vpn --advertise-exit-node

# Получаем и выводим Tailscale IP
TAILSCALE_IP=$(tailscale ip -4)
echo "=========================================="
echo "Tailscale VPN запущен!"
echo "IP адрес: $TAILSCALE_IP"
echo "Для подключения: ssh root@$TAILSCALE_IP"
echo "Пароль: password"
echo "=========================================="

# Запускаем SSH сервер
/usr/sbin/sshd -D