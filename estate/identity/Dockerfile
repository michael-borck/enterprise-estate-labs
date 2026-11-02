FROM alpine:3.20

RUN apk add --no-cache shadow sudo

COPY membership /etc/identity/membership
COPY entrypoint.sh /entrypoint.sh
COPY sudoers /etc/sudoers.d/ops

RUN chmod 440 /etc/sudoers.d/ops && chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
