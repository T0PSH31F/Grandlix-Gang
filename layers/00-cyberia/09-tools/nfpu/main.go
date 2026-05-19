package main

import (
	"fmt"
	"log"
	"nfpu/registry"
)

func main() {
	reg, err := registry.ExecuteNixEval("eval-registry.nix")
	if err != nil {
		log.Fatalf("Error: %v", err)
	}
	fmt.Printf("Successfully loaded registry for %d machines.\n", len(reg))
}
