# syntax=docker/dockerfile:1

##
## Build
##
FROM golang:1.18-buster AS build

ARG MINIVPN_BRANCH=latest-vpn-experiments2
ARG PROBECLI_BRANCH=feat/vpn-experiments

RUN git clone https://github.com/ainghazal/probe-cli /src/probe-cli
RUN git clone https://github.com/ainghazal/minivpn /src/minivpn
WORKDIR /src/minivpn
RUN git checkout $MINIVPN_BRANCH
WORKDIR /src/probe-cli
RUN git checkout $PROBECLI_BRANCH
COPY ./go.work .
RUN go mod tidy
RUN go mod download -x
RUN go build -o /bin/miniooni ./internal/cmd/miniooni

##
## Deploy
##
FROM gcr.io/distroless/base-debian10
WORKDIR /
COPY --from=build /bin/miniooni /miniooni
USER nonroot:nonroot
ENTRYPOINT [ "/miniooni", "--home", "/dev/shm", "-o", "/dev/shm/report.jsonl" ]
