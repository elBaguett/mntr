FROM golang:1.25.3-alpine AS build
WORKDIR /app
COPY go.mod .
COPY main.go .
COPY go.sum .
RUN go build -o app .

FROM scratch
COPY --from=build /app/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]