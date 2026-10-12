{ pkgs, ... }:
pkgs.writeShellScriptBin "hetzner-setup" ''
  HCLOUD="${pkgs.lib.getExe pkgs.hcloud}"
  HCLOUD_ARGS=()

  snapshot_list () {
    $HCLOUD "''${HCLOUD_ARGS[@]}" image list --type snapshot
  }

  snapshot_create () {
    local snapshot_name=""
    local vm_name=""

    while (( $# > 0 )); do
      case $1 in
        -s|--snapshot-name)
          snapshot_name="$2"
          shift 2
          ;;
        -n|--vm-name)
          vm_name="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1" >&2
          return 1
          ;;
      esac
    done

    snapshot_id=$($HCLOUD "''${HCLOUD_ARGS[@]}" server create-image --type snapshot --description $snapshot_name $vm_name | ${pkgs.lib.getExe pkgs.gawk} '{print $2}')

    $HCLOUD "''${HCLOUD_ARGS[@]}" image enable-protection $snapshot_id delete
  }

  vm_create () {
    local server_name=""
    local server_type=""
    local server_location=""
    local snapshot=""

    while (( $# > 0 )); do
      case $1 in
        -s|--snapshot)
          snapshot_name="$2"
          shift 2
          ;;
        -n|--server)
          server_name="$2"
          shift 2
          ;;
        -t|--server-type)
          server_type="$2"
          shift 2
          ;;
        -l|--location)
          server_location="$2"
          shift 2
          ;;
        *)
          echo "Unknown option: $1" >&2
          return 1
          ;;
      esac
    done

    if [[ -z "$snapshot_name" ]]; then
      read -rp "Snapshot name: " snapshot_name
    fi

    if [[ -z "$server_name" ]]; then
      read -rp "Server name: " server_name
    fi

    if [[ -z "$server_type" ]]; then
      read -rp "Server type: " server_type
    fi

    if [[ -z "$server_location" ]]; then
      read -rp "Server location: " server_location
    fi

    if [[ -z "$snapshot_name" || -z "$server_name" || -z "$server_type" || -z "$server_location" ]]; then
      echo "Missing required parameters" >&2
      exit 1
    fi

    snapshot_id=$($HCLOUD "''${HCLOUD_ARGS[@]}" image list --type snapshot -o json | ${pkgs.lib.getExe pkgs.jq} '.[] | select(.description == "nixos-base").id')

    output=$($HCLOUD "''${HCLOUD_ARGS[@]}" server create --image $snapshot_id --name $server_name --type $server_type --location $server_location -o json)

    $HCLOUD "''${HCLOUD_ARGS[@]}" server enable-protection $server_name delete
  }

  # Parse global flags first
  while (( $# > 0 )); do
    case $1 in
      --config)
        HCLOUD_ARGS+=(--config "$2")
        shift 2
        ;;
      --context)
        HCLOUD_ARGS+=(--context "$2")
        shift 2
        ;;
      *)
        break
        ;;
    esac
  done

  case $1 in
  snapshot)
      case $2 in
        list)
          snapshot_list
          exit 0
          ;;
        create)
          shift 2
          snapshot_create "$@"
          exit 0
          ;;
        *)
          echo "Invalid sub command for snapshot: $2" >&2
          exit 1
          ;;
      esac
      ;;
  create)
      shift 1
      vm_create "$@"
      exit 0
      ;;
  *)
      echo "Invalid command: $1" >&2
      exit 1
      ;;
  esac
''
