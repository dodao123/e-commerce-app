// Package model defines data structures for database entities.
package model

import "encoding/json"

// ProductOption represents a named option group with values.
// Example: {"name": "Color", "values": ["Red", "Blue"]}.
type ProductOption struct {
	// Name is the option group label (e.g. "Color", "Size").
	Name string `json:"name"`

	// Values is the list of selectable values.
	Values []string `json:"values"`
}

// ParseProductOptions decodes a JSONB byte slice into options.
func ParseProductOptions(raw []byte) []ProductOption {
	if len(raw) == 0 {
		return nil
	}
	var opts []ProductOption
	if err := json.Unmarshal(raw, &opts); err != nil {
		return nil
	}
	return opts
}

// EncodeProductOptions serializes options to JSON bytes.
func EncodeProductOptions(opts []ProductOption) []byte {
	if opts == nil {
		opts = []ProductOption{}
	}
	b, _ := json.Marshal(opts)
	return b
}
