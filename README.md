# solr-service

This will download and install Solr and contains the schema configuration for MSA.

As of right now, it does not configure for a production environment: merely a development or stage install.

This repository holds all the configuration necessary to install and setup Apache Solr complementary to Capitol Monitor.

*If you aren't familiar with the workings of Apache Solr,* the [reference guide](https://solr.apache.org/guide/) is a great resource. For further reading check out "Solr In Action".

## Solr's function in Capitol Monitor:

##### Capitol Monitor leverages Solr to provide all the following:

- A convenient API for searching legislation and regulation items efficiently and with great detail (exposed only to the backend).
- Useful analysis features like [faceting](https://solr.apache.org/guide/8_9/faceting.html) and [stats](https://solr.apache.org/guide/8_9/the-stats-component.html) for detailed reporting and visualization of searches.
- Full indexing of each item's original pdf file, enabling [full-text searching](https://en.wikipedia.org/wiki/Full-text_search).

##### Implementation Notes:

Capitol Monitor makes use of Solr's [Data Import Handler](https://solr.apache.org/guide/8_9/uploading-structured-data-store-data-with-the-data-import-handler.html) (DIH) to populate indexes from SQL querries.

In order to keep indexing speedy and storage requirements low, Solr's only stored field for each item is it's MySQL ID. When a search is performed, the full items must be subsequently retrieved via a MySQL query.

Any time an item is updated in MySQL, it must be re-indexed in Solr as to properly reflect changes in the index. Otherwise searches won't properly reflect the state of each item.

*Until decided otherwise, this repo is presently organized around running Solr in [standalone mode as opposed to SolrCloud](http://www.mtitek.com/tutorials/solr/overview.php).*
## Config

Set env vars in conf/solr.conf and conf/db.conf

Interactive configuration should run on first invocation (if you have make-do installed), but you can manually create the config files from the template as well.

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

## Common (Dev) Admin Operations

1. Copy the config from `dist` to your Solr installation's configset directory
	- *Staging: Copy to `/var/data/solr/configsets/`*
2. Delete all client cores and restart Solr.
	- *Staging: `cd var/data/solr` | `sudo rm -r core_*` | `sudo service solr restart`.*
3. Query `{your_base_url}/msa-capitol-monitor/v1/index-solr` to rebuild all client cores.
	-  *Staging: Open `https://staging.mainstreetadvocates.com/msa-capitol-monitor/v1/index-solr` in a local browser, ideally Firefox. (Helps review the job's output)*