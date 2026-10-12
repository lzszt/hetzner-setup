# Commands

Create a new snapshot of an existing VM with

    hcloud server create-image --type snapshot --description <snapshot-name> <vm-name>

Protect the snapshot against deletion with

    hcloud image enable-protection <snapshot-id> delete

List all available snapshots with

    hcloud image list --type snapshot

Create a new VM from a snapshot

    hcloud server create --image <snapshot-id> --name <vm-name> --type <vm-type> --location <vm-location>

Protect the new VM

    hcloud server enable-protection <vm-name> delete
