ARG PGGDOCKERTAG=16-alpine3.18
FROM postgres:$PGGDOCKERTAG AS pgvector-builder
RUN apk add git
RUN apk add build-base
RUN apk add clang15
RUN apk add llvm15-dev llvm15
RUN apk add postgresql-dev
WORKDIR /home
RUN git clone --branch v0.5.1 https://github.com/pgvector/pgvector.git
WORKDIR /home/pgvector
RUN make
RUN make install

FROM postgres:$PGGDOCKERTAG
COPY --from=pgvector-builder /usr/local/lib/postgresql/bitcode/vector.index.bc /usr/local/lib/postgresql/bitcode/vector.index.bc
COPY --from=pgvector-builder /usr/local/lib/postgresql/vector.so /usr/local/lib/postgresql/vector.so
COPY --from=pgvector-builder /usr/local/share/postgresql/extension /usr/local/share/postgresql/extension

# docker build -t postgres:alpine-pgvector --file ./dockerfiles/postgres.dockerfile ./dockerfiles
# docker run --name try-pgvector -p 5432:5432 -e POSTGRES_PASSWORD=yourcredkiddo -d postgres:alpine-pgvector 