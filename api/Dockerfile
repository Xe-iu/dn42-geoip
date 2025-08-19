# 使用官方 Golang 镜像构建
FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY . .

# 国内镜像
RUN go env -w GOPROXY=https://goproxy.cn,direct

RUN go mod download

RUN go build -o api .

FROM alpine:latest

WORKDIR /app

COPY --from=builder /app/api .

# 设置默认命令，可通过 docker run 覆盖
ENTRYPOINT ["/app/api"]
