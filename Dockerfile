FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder
ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=version-not-set
ARG GIT_COMMIT=git-commit-not-set
ARG BUILD_DATE=build-date-not-set

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN printf '{\n  "Version": "%s",\n  "BuildDate": "%s",\n  "GitCommit": "%s"\n}\n' \
      "${VERSION}" "${BUILD_DATE}" "${GIT_COMMIT}" > cmd/envvars/version.json
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -ldflags "-s -w -extldflags \"-static\"" -o bin/envvars cmd/envvars/main.go

FROM scratch
LABEL maintainer "@flemay"
COPY --from=builder /app/bin/envvars /
ENTRYPOINT [ "/envvars" ]
