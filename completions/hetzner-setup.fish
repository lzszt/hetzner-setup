# Fish completions for hetzner-setup

# Disable file completions by default
complete -c hetzner-setup -f

# Extract --config and --context from the current command line
function __hetzner_setup_hcloud_args
    set -l tokens (commandline -opc)
    set -l args
    set -l i 2
    while test $i -le (count $tokens)
        switch $tokens[$i]
            case --config
                set i (math $i + 1)
                set -a args --config $tokens[$i]
            case --context
                set i (math $i + 1)
                set -a args --context $tokens[$i]
        end
        set i (math $i + 1)
    end
    for a in $args
        echo $a
    end
end

# Dynamic completions
function __hetzner_setup_snapshots
    hcloud (__hetzner_setup_hcloud_args) image list --type snapshot -o json 2>/dev/null | jq -r '.[] | "\(.id)\t\(.description)"'
end

function __hetzner_setup_server_types
    hcloud (__hetzner_setup_hcloud_args) server-type list -o noheader -o columns=name 2>/dev/null
end

function __hetzner_setup_locations
    hcloud (__hetzner_setup_hcloud_args) location list -o json 2>/dev/null | jq -r '.[] | "\(.name)\t\(.description)"'
end

function __hetzner_setup_servers
    hcloud (__hetzner_setup_hcloud_args) server list -o noheader -o columns=name 2>/dev/null
end

# Conditions
function __hetzner_setup_needs_command
    not __fish_seen_subcommand_from snapshot create
end

function __hetzner_setup_using_command
    set -l cmds $argv
    __fish_seen_subcommand_from $cmds
end

# Global flags
complete -c hetzner-setup -l config -d "Path to hcloud config file" -r
complete -c hetzner-setup -l context -d "hcloud context to use" -r

# Top-level subcommands
complete -c hetzner-setup -n __hetzner_setup_needs_command -a snapshot -d "Manage snapshots"
complete -c hetzner-setup -n __hetzner_setup_needs_command -a create -d "Create a new VM from a snapshot"

# snapshot subcommands
complete -c hetzner-setup -n "__hetzner_setup_using_command snapshot; and not __fish_seen_subcommand_from list create" -a list -d "List all snapshots"
complete -c hetzner-setup -n "__hetzner_setup_using_command snapshot; and not __fish_seen_subcommand_from list create" -a create -d "Create a snapshot of a running VM"

# snapshot create flags
complete -c hetzner-setup -f -n "__hetzner_setup_using_command snapshot; and __fish_seen_subcommand_from create" -s s -l snapshot-name -d "Name for the snapshot" -r
complete -c hetzner-setup -f -n "__hetzner_setup_using_command snapshot; and __fish_seen_subcommand_from create" -s n -l vm-name -d "VM to snapshot" -r -a "(__hetzner_setup_servers)"

# create (vm) flags
complete -c hetzner-setup -f -n "__hetzner_setup_using_command create; and not __hetzner_setup_using_command snapshot" -s s -l snapshot -d "Snapshot to use" -r -a "(__hetzner_setup_snapshots)"
complete -c hetzner-setup -f -n "__hetzner_setup_using_command create; and not __hetzner_setup_using_command snapshot" -s n -l server -d "Server name" -r
complete -c hetzner-setup -f -n "__hetzner_setup_using_command create; and not __hetzner_setup_using_command snapshot" -s t -l server-type -d "Server type" -r -a "(__hetzner_setup_server_types)"
complete -c hetzner-setup -f -n "__hetzner_setup_using_command create; and not __hetzner_setup_using_command snapshot" -s l -l location -d "Server location" -r -a "(__hetzner_setup_locations)"
