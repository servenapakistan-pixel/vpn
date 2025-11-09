FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    openssh-server \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Установка Tailscale
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Настройка SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Копирование скрипта запуска
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]