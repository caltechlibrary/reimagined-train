#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "😵 SCRIPT MUST BE RUN AS ROOT"
    echo "EXAMPLE: sudo /bin/sh $0 [<ISO DATE>]"
    exit 1
fi

# SET THE ENVIRONMENT VARIABLES
# shellcheck source=/dev/null
. "$(dirname "$(readlink -f "$0")")"/export.sh

# allow the user to optionally specify a local file path
backups_dir="$(dirname "$(readlink -f "$0")")"/backups
# use the value of $TMPDIR if it is set, otherwise use /tmp
# see https://www.grymoire.com/Unix/Sh.html#uh-32
tmp_dir=${TMPDIR-/tmp}
if [ -z "$1" ]; then
    echo "GETTING BACKUP DATABASE..."
    # NOTE the filenames are named for the date they were generated (which is just after noon UTC)
    # $ /usr/local/bin/aws --profile example s3 ls s3://example-bucket/
    # ...
    # 2024-06-26 12:06:36   22551504 2024-06-26.sql.gz
    datestamp=$(TZ=':US/Pacific' date +'%Y-%m-%d')
else
    datestamp="$1"
fi

# set the local filepath
local_filepath="${backups_dir}/archivesspace-${datestamp}.sql.gz"
# download the file if it doesn’t exist
if [ ! -f "$local_filepath" ]; then
    # Download ArchivesSpace backup from S3.
    # NOTE we use a specific credentials profile for AWS
    script_directory=$(dirname "$(readlink -f "$0")")
    export AWS_SHARED_CREDENTIALS_FILE="${script_directory}/.aws/credentials"
    s3path="s3://${S3_BUCKET_NAME}/${datestamp}.sql.gz"
    if ! /usr/local/bin/aws --profile "$AWS_PROFILE" s3 cp "$s3path" "$tmp_dir" --no-progress; then
        echo "😵 FAILED TO DOWNLOAD BACKUP DATABASE FROM S3."
        exit 1
    fi
    mv "${tmp_dir}/${datestamp}.sql.gz" "$local_filepath"
fi

echo "RESETTING EXISTING DATABASE..."
mysql -e "DROP DATABASE IF EXISTS ${DB_NAME}; CREATE DATABASE ${DB_NAME} DEFAULT CHARACTER SET utf8mb4; CREATE USER IF NOT EXISTS 'as'@'localhost' IDENTIFIED BY 'as123'; GRANT ALL ON ${DB_NAME}.* to 'as'@'localhost'; ALTER USER 'as'@'localhost' IDENTIFIED WITH mysql_native_password BY 'as123';"

echo "IMPORTING BACKUP DATABASE..."
zcat "$local_filepath" | mysql "$DB_NAME"

echo "RESETTING PASSWORD..."
/opt/archivesspace/scripts/password-reset.sh admin admin
