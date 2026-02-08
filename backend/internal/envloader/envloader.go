// Package envloader reads .env files and sets environment variables.
package envloader

import (
	"bufio"
	"os"
	"strings"
)

// Load reads a .env file and sets the key-value pairs as environment variables.
// Existing environment variables are NOT overwritten.
func Load(filePath string) error {
	file, err := os.Open(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())

		// Skip empty lines and comments
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		parts := strings.SplitN(line, "=", 2)
		if len(parts) != 2 {
			continue
		}

		key := strings.TrimSpace(parts[0])
		value := strings.TrimSpace(parts[1])

		// Do not overwrite existing env vars
		if _, exists := os.LookupEnv(key); !exists {
			os.Setenv(key, value)
		}
	}

	return scanner.Err()
}
