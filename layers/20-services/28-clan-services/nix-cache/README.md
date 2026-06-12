# nix-cache clanService

Serve the nix store between machines in your network.

## Description

This service uses `harmonia` to share your `/nix/store` with other machines in the network.
It automatically handles signing key generation and configuration for both server and client roles.

## Usage

Enable the `server` role on the machine that should serve the cache, and the `client` role on machines that should consume it.
