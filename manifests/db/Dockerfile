FROM alpine:3.19

RUN apk add --no-cache \
    python3=3.11.14-r0 \
    py3-pip \
    build-base \
    linux-headers \
    python3-dev \
    postgresql16 \
    postgresql16-contrib \
    postgresql16-dev \
    su-exec \
    libc6-compat

RUN ln -sf python3 /usr/bin/python
RUN python3 -m venv /patroni-venv
ENV PATH="/patroni-venv/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install --no-cache-dir patroni[etcd] psycopg2-binary
# ------------------------------------------
COPY patroni.yaml /etc/patroni.yaml

EXPOSE 5432 8008

RUN mkdir -p /var/lib/postgresql/data && chown postgres:postgres /var/lib/postgresql/data

USER postgres

ENTRYPOINT ["patroni", "/etc/patroni.yaml"]