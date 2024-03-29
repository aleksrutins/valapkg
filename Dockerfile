FROM quay.io/fedora/fedora:37

RUN dnf install -y meson ninja-build wget gcc git vala glib-devel libsoup3-devel libgee-devel json-glib-devel libpq-devel libxml2-devel

ADD . /app
WORKDIR /app

ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}

RUN meson builddir -Dbuild_server=true -Dbuild_client=false && ninja -C builddir

ARG SECRET_KEY
ENV SECRET_KEY=${SECRET_KEY}

ARG PORT
ENV PORT=${PORT}

CMD [ "/app/builddir/server/valapkg-server" ]
