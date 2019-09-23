# solr-service

This will download and install Solr.
As of right now, it does not configure for a production environment: merely a development or stage install.

## Config

Set env vars in conf/solr.conf and conf/db.conf

Interactive configuration should run on first invocation (if you have make-do installed).

## Principal Targets

 - install
 - uninstall
 - downloads

 ## MSA ConfigSet

 The target `deploy-configset` will generate and deploy the MSA schema and DataImport Handler.
