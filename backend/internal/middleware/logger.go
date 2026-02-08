// Package middleware provides HTTP middleware for the API server.
package middleware

import (
	"log"
	"net/http"
	"time"
)

// responseRecorder wraps http.ResponseWriter to capture the status code.
type responseRecorder struct {
	http.ResponseWriter
	statusCode int
}

// WriteHeader captures the status code before delegating to the original writer.
func (recorder *responseRecorder) WriteHeader(code int) {
	recorder.statusCode = code
	recorder.ResponseWriter.WriteHeader(code)
}

// ApplyLogger wraps an HTTP handler with request logging.
func ApplyLogger(next http.Handler) http.Handler {
	return http.HandlerFunc(
		func(writer http.ResponseWriter, request *http.Request) {
			startTime := time.Now()

			recorder := &responseRecorder{
				ResponseWriter: writer,
				statusCode:     http.StatusOK,
			}

			next.ServeHTTP(recorder, request)

			duration := time.Since(startTime)
			log.Printf(
				"[%s] %s %s → %d (%v)",
				request.Method,
				request.RemoteAddr,
				request.URL.Path,
				recorder.statusCode,
				duration,
			)
		},
	)
}
