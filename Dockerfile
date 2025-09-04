# syntax=docker/dockerfile:1

# --- Build stage ---
FROM golang:1.25 AS build
WORKDIR /src

# Copy module files first for better caching
COPY go.mod .
RUN go mod download

# Copy the rest of the source
COPY . .

# Build static binary
RUN --mount=type=secret,id=aes.key,target=/src/internal/crypto/aes.key \
  CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/pocketvault .

# --- Runtime stage ---
FROM alpine:3.20 AS runtime

RUN adduser -D -u 10001 app
WORKDIR /
COPY --from=build /out/pocketvault /pocketvault
USER app

ENTRYPOINT ["tail", "-f", "/dev/null"]