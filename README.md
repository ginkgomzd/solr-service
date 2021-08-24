# Capitol Monitor - Solr
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

Any time an item's updated in MySQL, it must be re-indexed in Solr as to properly reflect changes in the index. Otherwise searches won't properly reflect the state of each item.

*Until decided otherwise, this repo is presently organized around running Solr in [standalone mode as opposed to SolrCloud](http://www.mtitek.com/tutorials/solr/overview.php).*

## Instructions:

**Disclaimer: These instructions are as-built.**

### Setting up this repo:
1. Set the environment variables in the `conf` directory according to your setup.

### Installing Solr locally:
Solr can be installed locally by following the [reference guide](https://solr.apache.org/guide/8_9/installing-solr.html) or using your preferred package manager. Either way just be sure to use an equivalent version.

**MacOS:** `brew install solr` *(Note: excludes example files)*

You'll also need to install the Java Database Connectivity (JDBC) driver for MySQL in your Solr instance:

1. Download the platform independent connector from [dev.mysql.com](https://dev.mysql.com/downloads/connector/j/).
2. Open the archive and copy the included `mysql-connector-java-X.X.XX.jar` file to your Solr installation's `server/lib` directory.
3. Restart Solr for the changes to take effect.

### Deploying the configset:
1. Build the configset using `go run build.go -c "path/to/config.json"`.
2. Copy the config from `dist` to your Solr installation's configset directory
    - *Staging: Copy to `/var/data/solr/configsets/`*
3. Delete all client cores and restart Solr.
    - *Staging: `cd var/data/solr` | `sudo rm -r core_*` | `sudo service solr restart`.*
4. Query `{your_base_url}/msa-capitol-monitor/v1/index-solr` to rebuild all client cores.
    -  *Staging: Open `https://staging.mainstreetadvocates.com/msa-capitol-monitor/v1/index-solr` in a local browser, ideally Firefox. (Helps review the job's output)*

#### Configset Notes:
 MSA makes use of Solr's Data Import Handler to populate indexes from SQL querries, which are defined in `db-data-config.xml`.
 This file is in `.gitignore` because we're generating it from the `db-data-config.tpl` template.
 
 The database querries are defined in `db-data-config-schema.xml` because we need to generate the config-xml from a template, and it would just be wrong to put versioned code into a template that should be static and easy to maintain.

## Installing Solr as a service:
***Todo:** This section will document how we'll configure Solr dedicated installations with all the bells and whistles.*

***The following instructions are intended for deploying Solr on a dedicated development, staging, or production environment.** Supported platforms include CentOS, Debian, RHEL, SUSE, and Ubuntu. While you can use this script for local setups, you may find its extra security, performance tunes, and run-at-startup more trouble than help.*

**Installing Solr as a service [`make install`]:**

**Starting/Stopping Solr [`make start|stop`]**
Same as `sudo service solr start` or `stop` accordingly.

**Removing Solr [make uninstall]:**

## Other utilities:

`make ping` - pings Solr and returns its present status

`make list-collections`

`make list-cores`
