FROM ubuntu:22.04

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && apt-get -y -f install \
        python3-pip \
        python3-proselint \
        shellcheck

ENTRYPOINT ["/entrypoint.sh"]
