# hetzner-setup

This tool tries to provide a way of creating new Hetzner Cloud VMs from a predefined snapshot
and then configure them after creation.

The tool is based on the offical [Hetzner Cloud CLI](https://github.com/hetznercloud/cli).

# Workflow

To use this tool you have to create a Hetzner VM manually via the Hetzner Cloud Web interface.
For all the features to be available, the created VM has to have SSH enabled and authorized keys set
for the users trying to setup new machines.
Then you can create a snapshot for later usage with `hetzner-setup snapshot create`.

From now on you can create new machines based on this snapshot and afterwards run commands for full setup.

## Architecture

This is a nixified CLI wrapper around hcloud.
