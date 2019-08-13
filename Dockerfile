FROM ubuntu:18.04
MAINTAINER Colin Harris <col.w.harris@gmail.com>

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -y locales libssl1.0.0 erlang-crypto postgresql-client && \
    localedef -i en_US -f UTF-8 en_US.UTF-8

ENV MIX_ENV=prod
COPY /home/semaphore/whos_in_bot/_build/prod/rel/whos_in_bot .

ENTRYPOINT ["whos_in_bot", "start"]