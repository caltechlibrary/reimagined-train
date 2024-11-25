#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
    echo "😵 SCRIPT MUST BE RUN WITH ROOT PRIVILEGES"
    echo "EXAMPLE: sudo /bin/sh $0"
    exit 1
fi

# SET ENVIRONMENT VARIABLES
# shellcheck source=/dev/null
. "$(dirname "$(readlink -f "$0")")"/export.sh

# REPLACE ARCHIVESSPACE DEFAULT CONFIGURATION WITH CUSTOM CONFIGURATION
echo '# Custom Configuration' > /opt/archivesspace/config/config.rb
{
    echo "AppConfig[:db_url] = 'jdbc:mysql://localhost:3306/${DB_NAME}?user=as&password=as123&useUnicode=true&characterEncoding=UTF-8'"
    echo 'AppConfig[:solr_url] = "http://localhost:8983/solr/archivesspace"'
    echo 'AppConfig[:plugins] = ["local", "lcnaf", "reindexer", "timewalk"]'
    echo 'AppConfig[:reindex_on_startup] = true'
    echo 'AppConfig[:session_expire_after_seconds] = 604800'
    echo 'AppConfig[:arks_enabled] = true'
    echo 'AppConfig[:ark_naan] = "99999"'
    echo "AppConfig[:ark_url_prefix] = '${ARK_URL_PREFIX}'"
} >> /opt/archivesspace/config/config.rb
echo '<%= stylesheet_link_tag "#{@base_url}/assets/custom.css" %>' > /opt/archivesspace/plugins/local/frontend/views/layout_head.html.erb
mkdir -p /opt/archivesspace/plugins/local/frontend/assets
echo 'body { border: thick solid fuchsia; min-height: 100vh; }' > /opt/archivesspace/plugins/local/frontend/assets/custom.css

# RESTORE ARCHIVESSPACE DATABASE FROM BACKUP
# shellcheck source=/dev/null
. "$(dirname "$(readlink -f "$0")")"/db.sh

# START ARCHIVESSPACE
/opt/archivesspace/archivesspace.sh start
