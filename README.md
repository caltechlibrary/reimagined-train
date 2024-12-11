# ArchivesSpace VM with Multipass & `cloud-init`

The `as4.yml` file contains cloud-init user-data that will configure Ubuntu with everything we use for a local ArchivesSpace instance.

The `rebuild.sh` script will destroy any existing instance and rebuild a new one.

The `start.sh` script will start a stopped or suspended instance.

Environment variables must be set in an `export.sh` file; see `export.sh-example` for required keys.
