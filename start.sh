#!/bin/bash

# Запускаем tailscaled
tailscaled --tun=userspace-networking --socket=/var/run/tailscale/tailscaled.sock &
sleep 5

echo "=========================================="
echo "Настройка Tailscale VPN"
echo "=========================================="

# Пытаемся использовать auth key (если он рабочий)
if [ -n "$TAILSCALE_AUTHKEY" ]; then
    echo "Пробую использовать Auth Key..."
    tailscale up --authkey="$TAILSCALE_AUTHKEY" --hostname=render-ssh-vpn --advertise-exit-node
fi

# Если auth key не сработал или не указан, используем интерактивную аутентификацию
if ! tailscale status > /dev/null 2>&1; then
    echo "Auth Key не сработал, перехожу к интерактивной аутентификации..."
    echo "ЗАПУСКАЕМ АУТЕНТИФИКАЦИЮ ПО ССЫЛКЕ..."
    
    # Запускаем аутентификацию и получаем ссылку
    AUTH_URL=$(tailscale up --hostname=render-ssh-vpn --advertise-exit-node --qr 2>&1 | grep -o 'https://login.tailscale.com/a/[^ ]*' | head -1)
    
    if [ -n "$AUTH_URL" ]; then
        echo "=========================================="
        echo "ДЛЯ АУТЕНТИФИКАЦИИ ПЕРЕЙДИТЕ ПО ССЫЛКЕ:"
        echo "$AUTH_URL"
        echo "=========================================="
        
        # Также выводим QR код если доступно
        tailscale up --hostname=render-ssh-vpn --advertise-exit-node --qr
    else
        echo "Не удалось получить ссылку для аутентификации"
        echo "Запускаю в интерактивном режиме..."
        tailscale up --hostname=render-ssh-vpn --advertise-exit-node
    fi
fi

# Ждем подключения и получаем IP
echo "Ожидаю подключения к Tailscale..."
for i in {1..30}; do
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null)
    if [ -n "$TAILSCALE_IP" ]; then
        break
    fi
    sleep 2
done

echo "=========================================="
echo "Tailscale VPN запущен!"
if [ -n "$TAILSCALE_IP" ]; then
    echo "IP адрес: $TAILSCALE_IP"
    echo "Для подключения: ssh root@$TAILSCALE_IP"
else
    echo "IP адрес: (ожидайте подключения)"
    echo "Проверьте статус: tailscale status"
fi
echo "Пароль: strike@#$"
echo "=========================================="

# Запускаем SSH сервер
/usr/sbin/sshd -D
