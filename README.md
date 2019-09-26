# solr-service

This will download and install Solr and contains the schema configuration for MSA.

As of right now, it does not configure for a production environment: merely a development or stage install.

## Config

Set env vars in conf/solr.conf and conf/db.conf

Interactive configuration should run on first invocation (if you have make-do installed).

The solr config file (`solr.conf`) is intentionally checked-in to VC for consistency across instances, and to track the version of Solr we are using. You may want to update the mirror used to download Solr.

## Principal Targets

- install
- uninstall
- downloads
- deploy-configset

## MSA ConfigSet

 The target `deploy-configset` will generate and deploy the MSA schema and DataImport Handler.

## Data Import Handler

 MSA makes use of the Data Import Handler of Solr to populate indexes from SQL querries.

 Solr requires these to be defined in db-data-config.xml.
 This file is in `.gitignore` because we are generating it from the template: `db-data-config.tpl`.
 
 The database querries are defined in `db-data-config-schema.xml` because we need to generate the config-xml from a template, and it would just be wrong to put versioned code into a template that should be static and easy to maintain. See the recipe for `deploy-configset`.
