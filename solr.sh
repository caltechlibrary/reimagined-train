#!/bin/sh

export ARCHIVESSPACE_HOME=/opt/archivesspace
export SOLR_VERSION=9.7.0
export SOLR_ROOT=/opt/solr
export SOLR_HOME="$SOLR_ROOT/server/solr"

curl --silent --location "https://archive.apache.org/dist/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz" --output "/var/tmp/solr-${SOLR_VERSION}.tgz"
tar xzf /var/tmp/solr-${SOLR_VERSION}.tgz solr-${SOLR_VERSION}/bin/install_solr_service.sh --strip-components=2
bash ./install_solr_service.sh /var/tmp/solr-${SOLR_VERSION}.tgz
echo "SOLR_MODULES=analysis-extras" >> /etc/default/solr.in.sh
echo "SOLR_JETTY_HOST=0.0.0.0" >> /etc/default/solr.in.sh
mkdir --parents "$SOLR_HOME/configsets/archivesspace/conf"
cp "$ARCHIVESSPACE_HOME/solr/schema.xml" "$SOLR_HOME/configsets/archivesspace/conf/"
curl --silent --location "https://gist.github.com/t4k/3d0173a1d265a2693fd165b6c0808881/raw/d8513ffc49d5d53ce7ea81dc20c9db1c41ab848a/solrconfig.xml" --output "$SOLR_HOME/configsets/archivesspace/conf/solrconfig.xml"
cp "$ARCHIVESSPACE_HOME/solr/stopwords.txt" "$SOLR_HOME/configsets/archivesspace/conf/"
cp "$ARCHIVESSPACE_HOME/solr/synonyms.txt" "$SOLR_HOME/configsets/archivesspace/conf/"
su --login solr --command "$SOLR_ROOT/bin/solr create -c archivesspace -d archivesspace"
rm /var/tmp/solr-${SOLR_VERSION}.tgz
service solr restart
