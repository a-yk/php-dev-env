FROM httpd:2.4

ARG USER_UID=1000
ARG USER_GID=1000

RUN addgroup --gid ${USER_UID} app && adduser --uid ${USER_UID} --gid ${USER_UID} --shell /bin/sh app

CMD ["httpd-foreground"]
