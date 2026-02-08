.PHONY: run build clean

# Run the server in development mode
run:
	go run ./cmd/server/main.go

# Build the production binary
build:
	go build -o bin/server.exe ./cmd/server/main.go

# Clean build artifacts
clean:
	rm -rf bin/
