FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    ca-certificates \
    curl \
    dnsutils \
    git \
    iproute2 \
    iputils-ping \
    less \
    man-db \
    nano \
    net-tools \
    openssh-client \
    procps \
    psmisc \
    rsync \
    strace \
    sudo \
    supervisor \
    tree \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

ARG USERNAME=student
ARG USER_UID=1000
ARG USER_GID=1000

# Ubuntu 24.04 ships an `ubuntu` user at UID/GID 1000. Remove it so the
# student account can use the conventional first-user IDs.
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupdel ubuntu 2>/dev/null || true

RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}" \
    && echo "${USERNAME}:cloudcore" | chpasswd \
    && echo "${USERNAME} ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

COPY scripts/heartbeat.sh /usr/local/bin/heartbeat.sh
COPY config/supervisor/heartbeat.conf /etc/supervisor/conf.d/heartbeat.conf
RUN chmod +x /usr/local/bin/heartbeat.sh \
    && chmod 0644 /etc/supervisor/conf.d/heartbeat.conf

USER ${USERNAME}
WORKDIR /home/${USERNAME}

CMD ["bash"]
