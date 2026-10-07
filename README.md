# hetzner-setup

A stateless CLI wrapper around the official [Hetzner Cloud CLI](https://github.com/hetznercloud/cli)
for creating VMs from predefined snapshots.

Post-creation provisioning (e.g., `nixos-rebuild switch --target-host`) is out of scope
and left to external tooling.

## Workflow

1. Create a Hetzner VM manually via the Hetzner Cloud web interface.
2. Configure the VM with SSH enabled and authorized keys set.
3. Create a snapshot with `hetzner-setup snapshot create`.
4. Create new machines from that snapshot with `hetzner-setup create`.

## Commands

### `hetzner-setup create`

Create a new VM from a snapshot. Configurable parameters:

- `--name` — server name
- `--type` — server type (e.g., cx22, cx32)
- `--location` — datacenter location (e.g., fsn1, nbg1)
- `--snapshot` — snapshot to use
- `--token-file` — path to file containing the Hetzner API token (overrides `HCLOUD_TOKEN`)
- `--json` — output machine-readable JSON instead of a human-readable summary

All parameters can be provided as flags. Any missing parameters are prompted for
interactively via the terminal.

The command prints progress at each step and waits until the server is SSH-reachable
before completing. On success, it prints a summary with the server name, IP address,
and a ready-to-use SSH command.

### `hetzner-setup snapshot create`

Create a snapshot of a running VM.

### `hetzner-setup snapshot list`

List all snapshots in the Hetzner project.

## Authentication

The tool supports two methods for providing the Hetzner API token:

1. `HCLOUD_TOKEN` environment variable
2. `--token-file` flag (reads the token from a file, takes precedence over the env var)

For NixOS users, a separate home-manager module handles token injection via agenix.

## Architecture

This is a pure bash CLI packaged as a Nix flake using `writeShellApplication`.
The only runtime dependency is `hcloud`.
