FROM ubuntu:18.04

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y ca-certificates locales libssl1.0.0 erlang-crypto postgresql-client && \
    localedef -i en_US -f UTF-8 en_US.UTF-8

ADD priv/certs/db-ca-certificate.crt /usr/local/share/ca-certificates/DO-PG-CA.crt
RUN chmod 644 /usr/local/share/ca-certificates/DO-PG-CA.crt && update-ca-certificates

ENV MIX_ENV=prod
COPY _build/prod/rel/whos_in_bot .

ENTRYPOINT ["whos_in_bot", "start"]