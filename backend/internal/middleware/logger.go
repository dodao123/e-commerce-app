// Package middleware provides HTTP middleware for the API server.
package middleware

import (
	"bufio"
	"errors"
	"log"
	"net"
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

// Hijack delegates connection hijacking to the underlying response writer if supported.
func (recorder *responseRecorder) Hijack() (net.Conn, *bufio.ReadWriter, error) {
	hijacker, ok := recorder.ResponseWriter.(http.Hijacker)
	if !ok {
		return nil, nil, errors.New("underlying ResponseWriter does not implement http.Hijacker")
	}
	return hijacker.Hijack()
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
