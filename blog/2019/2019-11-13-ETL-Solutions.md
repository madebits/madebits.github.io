# ETL Solutions

This post is based on an opinionated review of discussion of a HackerNews [entry](https://news.ycombinator.com/item?id=21513566), which lists also a [registry](https://github.com/thenaturalist/awesome-business-intelligence) of such tools.

## Extract - Transform - Load

[Extract Transform Load (ETL)](https://en.wikipedia.org/wiki/Extract,_transform,_load) in the name used for the **generic** procedure of collecting data from various sources into a [data warehouse](http://tdan.com/data-warehouse-design-inmon-versus-kimball/20300#) and preparing them for running analytics.

* *Extract* refers to the process of fetching the raw data from their original data sources. The raw data is in different formats and can come batched or full.
* *Transform* is the process of transforming data to fit to same data warehouse format to support further analytics. There are different transformations that can be applied to different stages ([ELT/ETL](https://www.dataliftoff.com/elt-with-amazon-redshift-an-overview/)). One can transform the data before loading in the data warehouse, or load them in raw form and transform later, or transform while loading and also later.
* *Load* is the process of storing data in a data warehouse to make them available for further analytics processing.

## Analytics

* [Metabase](https://www.metabase.com/docs/latest/users-guide/01-what-is-metabase) is a business intelligent tool based on SQL databases. Metabase [cannot](https://github.com/metabase/metabase/issues/3953) combine data between DBs, but can query and visualize data within a DB.
* [Redash](https://redash.io/) a tool to connect, query (native language of connected DB) and visualize data from various sources.
* [Looker](https://looker.com/) business intelligence tool and data platform.
* [PopSQL](https://popsql.com/) share SQL queries with team and visualize the data.
* [Holistics](https://www.holistics.io/) full data flow analytics platform.
* [Periscope Data](https://www.periscopedata.com/) combined data analytics with SQL, Python, R.
* [Mode](https://mode.com/) data analytics with SQL, Python, R.
* [Tableau](https://www.tableau.com/) business analytics tools (the only one I have used).
* [Klipfolio](https://www.klipfolio.com/) business analytics tool.
* [Kloud.io](https://kloud.io/) automated ETL reporting tool.
* [Forest](https://www.forestadmin.com/) dashboard tool.
* [Rakam](https://rakam.io/) analytics without coding.
* [Grafana](https://grafana.com/) analytics and monitoring.
* [Data Monkey](https://www.data-monkey.com/) clean and transform small scale data.
* [Sigma](https://www.sigmacomputing.com/product/) data analytics.
* [IBM Cognos](https://www.ibm.com/products/cognos-analytics) business intelligence platform.
* [PowerBI](https://powerbi.microsoft.com/en-us/) data analytics.
* [SuperSet](https://superset.incubator.apache.org/) data analytics.
* [Frame.ai](https://frame.ai/) analytics over customer text messages.

## Storage

* [PostgreSQL](https://www.postgresql.org/) is a row-oriented DB, which can [optionally](https://wiki.postgresql.org/wiki/ColumnOrientedSTorage) support column-oriented table storage.
* [Amazon Redshift](https://en.wikipedia.org/wiki/Amazon_Redshift) a massive parallel processing column-oriented cloud data warehouse DB from Amazon. [Redshift Spectrum](https://docs.aws.amazon.com/redshift/latest/dg/c-getting-started-using-spectrum.html) can use SQL to query data directly from S3 files (see also [Athena](https://aws.amazon.com/athena/)).
* [ADLS](https://azure.microsoft.com/en-us/services/storage/data-lake-storage/) is Azure data lake storage.
* [BigQuery](https://cloud.google.com/bigquery/) Google cloud data warehouse storage.
* [ClickHouse](https://clickhouse.yandex/) column-oriented DB.
* [Druid](https://druid.apache.org/) analytics database.

## Infrastructure

* [Zapier](https://zapier.com/) a workflow tool. Can combine data from different services using JS as workflow script language.
* [DataForm](https://dataform.co/) a platform to manage and transform warehouse data.
* [Dbt](https://www.getdbt.com/) a command line tool to manage data warehouse transformations using SQL.
* [Luigi](https://github.com/spotify/luigi) workflow management system (WMS) for Python.
* [Airflow](https://airflow.apache.org/) WMS tool for static workflows.
* [Stitch](https://www.stitchdata.com/) a platform to manage ETL data workflows.
* [Fivetran](https://fivetran.com/) collect and transformation data for snowflake warehouse storage.
* [Matillion](https://www.matillion.com/) ETL tool for cloud warehouses.
* [Informatica](https://www.informatica.com/solutions.html) data warehouse solutions.
* [Dremio](https://www.dremio.com/) data lake queries.
* [Domo](https://www.domo.com/) data analytics solution.
* [Imply](https://imply.io/) real-time data analytics.
* [Retool](https://retool.com/) quick data reporting prototype tool.

## Marketing Analytics

* [Segment](https://segment.com/docs/guides/general/what-is-segment/) can be used to collect and provide data to other services (similar to Google Analytics).
* [Snowplow Analytics](https://snowplowanalytics.com/) collect and manage real-time product data. Snowflake DB is a data warehouse product.
* [Amplitude](https://amplitude.com/) and [Mixpanel](https://mixpanel.com/) are product intelligence [tools](https://effinamazing.com/blog/mixpanel-vs-amplitude/).
* [Heap](https://heap.io/) product analytics.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2019/2019-09-04-Agile-Backlog-As-Gantt-Frontier.md'>Agile Backlog As Gantt Frontier</a></ins>
