package main

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/jackc/pgx/v5"
)

func handler(w http.ResponseWriter, r *http.Request) {
	connStr := "postgres://postgres:password@patroni.mntr.svc.cluster.local:5432/postgres?sslmode=disable"
	conn, err := pgx.Connect(context.Background(), connStr)
	if err != nil {
		fmt.Fprintf(w, "DB CONNECT ERROR: %s\n", err.Error())
		return
	}
	defer conn.Close(context.Background())

	var now time.Time
	err = conn.QueryRow(context.Background(), "SELECT now()").Scan(&now)
	if err != nil {
		fmt.Fprintf(w, "DB QUERY ERROR: %s\n", err.Error())
		return
	}

	fmt.Fprintf(w, "It works! The current DB time is: %s\n", now.Format(time.RFC3339))
}

func main() {
	http.HandleFunc("/", handler)
	http.ListenAndServe(":8080", nil)
}
