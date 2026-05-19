package registry

import (
	"encoding/json"
	"fmt"
	"os/exec"
)

// Raw representation of the Nix output
type RawMachineConfig struct {
	Services map[string]interface{} `json:"services"`
}

type Registry map[string]RawMachineConfig

// ExecuteNixEval runs the nix eval command and returns the parsed Registry
func ExecuteNixEval(nixFilePath string) (Registry, error) {
	cmd := exec.Command("nix", "eval", "--json", "-f", nixFilePath)
	output, err := cmd.Output()
	if err != nil {
		return nil, fmt.Errorf("nix eval failed: %v", err)
	}

	var reg Registry
	if err := json.Unmarshal(output, &reg); err != nil {
		return nil, fmt.Errorf("failed to parse JSON: %v", err)
	}

	return reg, nil
}
