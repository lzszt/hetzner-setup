# Bash completions for hetzner-setup

_hetzner_setup() {
    local cur prev words cword
    _init_completion || return

    # Find the subcommand position (skip global flags)
    local subcmd="" subcmd_idx=0
    local i=1
    while [[ $i -lt $cword ]]; do
        case "${words[$i]}" in
            --config|--context)
                ((i += 2))
                ;;
            snapshot|create)
                subcmd="${words[$i]}"
                subcmd_idx=$i
                break
                ;;
            *)
                ((i++))
                ;;
        esac
    done

    # Global flags
    if [[ "$cur" == -* && -z "$subcmd" ]]; then
        COMPREPLY=($(compgen -W "--config --context" -- "$cur"))
        return
    fi

    # No subcommand yet
    if [[ -z "$subcmd" ]]; then
        COMPREPLY=($(compgen -W "snapshot create" -- "$cur"))
        return
    fi

    case "$subcmd" in
        snapshot)
            local sub2="${words[$((subcmd_idx + 1))]}"
            if [[ $cword -eq $((subcmd_idx + 1)) ]]; then
                COMPREPLY=($(compgen -W "list create" -- "$cur"))
                return
            fi
            if [[ "$sub2" == "create" ]]; then
                case "$prev" in
                    -n|--vm-name)
                        local servers
                        servers=$(hcloud server list -o noheader -o columns=name 2>/dev/null)
                        COMPREPLY=($(compgen -W "$servers" -- "$cur"))
                        return
                        ;;
                    -s|--snapshot-name)
                        return
                        ;;
                esac
                if [[ "$cur" == -* ]]; then
                    COMPREPLY=($(compgen -W "-s --snapshot-name -n --vm-name" -- "$cur"))
                fi
            fi
            ;;
        create)
            case "$prev" in
                -s|--snapshot)
                    local snapshots
                    snapshots=$(hcloud image list --type snapshot -o noheader -o columns=id,description 2>/dev/null | awk '{print $1}')
                    COMPREPLY=($(compgen -W "$snapshots" -- "$cur"))
                    return
                    ;;
                -t|--server-type)
                    local types
                    types=$(hcloud server-type list -o noheader -o columns=name 2>/dev/null)
                    COMPREPLY=($(compgen -W "$types" -- "$cur"))
                    return
                    ;;
                -l|--location)
                    local locations
                    locations=$(hcloud location list -o noheader -o columns=name 2>/dev/null)
                    COMPREPLY=($(compgen -W "$locations" -- "$cur"))
                    return
                    ;;
                -n|--server)
                    return
                    ;;
            esac
            if [[ "$cur" == -* ]]; then
                COMPREPLY=($(compgen -W "-s --snapshot -n --server -t --server-type -l --location" -- "$cur"))
            fi
            ;;
    esac
}

complete -F _hetzner_setup hetzner-setup
