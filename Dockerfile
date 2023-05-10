FROM arm64v8/golang:1.20.4-buster as build
LABEL maintainer="Infinity Works"

ENV GO111MODULE=on

COPY ./ /go/src/github.com/infinityworks/github-exporter
WORKDIR /go/src/github.com/infinityworks/github-exporter

RUN go mod download \
    && go test ./... \
    && CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o /bin/main

FROM arm64v8/alpine:3.18.0

RUN apk --no-cache add ca-certificates \
     && addgroup exporter \
     && adduser -S -G exporter exporter
ADD VERSION .
USER exporter
COPY --from=build /bin/main /bin/main
ENV LISTEN_PORT=9171
EXPOSE 9171
ENTRYPOINT [ "/bin/main" ]
