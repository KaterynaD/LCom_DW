# Profiles for tables and views created by Fivetran

There are base and custom tables with hundreds (100 - 500) columns

### dbt_profiler

The package is used to create profiles however it does not work out of the box with our Redshift serverless. 
There are not very clear database errors for almost all tables/views like:

SQL Error [XX000]: ERROR: query engine
  Detail: 
  -----------------------------------------------
  error:  query engine
  code:      1014
  context:   max rowsets exceeded
  query:     185611517[child_sequence:1]
  location:  tbl_trans.cpp:650
  process:   padbmaster [pid=1073865171]
  -----------------------------------------------

There are no errors if columns are separated by data type. It runs for all only "boolean" or "text" column sets but not if there is a mix of them.

The original approach to calculate nullable, distinct proportion and is_unique measures fails if it's an empty column.


To fix the issues I created my own macros to replace macros from the package:

macros/get_profile_redshift.sql

It replaces:

- default__get_profile
- default__measure_not_null_proportion
- default__measure_distinct_proportion
- default__measure_is_unique

The models failes if the source table is empty. This tables should be excluded from the analysis anyway.

The target schema must be in the same database as the analyzed tables. Information_Schema views are used to get the column type.

### Setup

I used this ChatGPT prompt to create 

project_setup_utils/setup_created_by_chatgpt.py


```

Create Python script to get not empty views in fivetran_salesforce_quickstart schema (<schema name>), rawdata database name (Redshift).
Read connection information from dbt profiles_salesforce_quickstart profile in the default file (C:\Users\KDrogaieva\.dbt).
Exclude these views:'data_lineage_node_sync_status','data_lineage_node_sync_status_feed', 'data_lineage_node_sync_status_history','incp_incident_lv_fields_c', 'incp_time_zone_selection_c'
Based on the found not empty views (Make sure each view (<view name>) contains at least 1 row.) run a query to get columns names for each view.
Use these information to create files according these rules:

1. Base folder: C:\Users\KDrogaieva\OneDrive - Learning.com\Development\dbt\transformations\dbt\profiles_salesforce_quickstart\models1

2. Sources
2.1 File name sources.yml
2.3 File content:

sources:
  - name: <schema name>
    quoting:
      database: false
      schema: false
      identifier: false    
    tables:
      - name: <view name>

Important! Only - name: <view name> is repeated for each view. The header (everything above) included just once

4. Creation steps:
4.1 Create folder <view name> in the base folder
4.2 Create files for all columns in the view, but include no more then 50 columns grouped by column date type in each file according to the template:
4.2.1 File name: <view name>_part_<number>.sql
4.2.2 File content:

-- depends_on: {{ source("<schema name>","<view name>") }}
{% if execute %}

  {{ dbt_profiler.get_profile(relation=source("<schema name>","<view name>"), exclude_measures=["min","max","avg","median","std_dev_population","std_dev_sample"], include_columns=[ <comma separated no more then 50 columns of the same date type> ]) }}
  
{% endif %}

Important! Do not mix column date types in one file. It should include no more then 50 column of teh same type: boolean, integer etc...


4.3 In the base folder create file according to this template:
4.3.1 File name: <view name>.sql
4.3.2 File content:

select * from {{ ref("<view name>_part_1") }}
union all
select * from {{ ref("<view name>_part_2") }}
union all
...
union all
select * from {{ ref("<view name>_part_<last_part_number>") }}

```
The python code created models and source.yml files after a small manual adjustment. ("{{" and "}}" were replaced with "{{{{" and "}}}}")



Fivetran created tables and columns names slightly different from the original Salesforce API names.

EntityDefinition and FieldDefinition were added in Fivetran connector scheama in test environment in April 2025
Now the data exist in seeds/entity_definition202504.csv and seeds/field_definition202504.csv
Not uptodate anymore, but can be used.

I created Salesforce.csv and Fivetran.csv files with table and column names from 2 systems (Run in Dbeaver or whatever and export in csv file, the header should be "table_name","column_name" (quotes!)):

```
select
lower(ed.qualified_api_name) table_name,
lower(fd.qualified_api_name) column_name
from fivetran_salesforce_quickstart.entity_definition ed
join fivetran_salesforce_quickstart.field_definition fd
on ed.durable_id = fd.entity_definition_id
order by table_name, column_name;
```
```
select c.table_name, c.column_name
from information_schema.columns c
join information_schema.views v
on c.table_name=v.table_name
and c.table_schema = v.table_schema
where c.table_schema = 'fivetran_salesforce_quickstart'
order by table_name, column_name;
```

I used this prompt to create 

project_setup_utils/mapping.py

to create csv file with mapping between Fivetran and original Salesforce column names. 

```
Create actual mapping between Salesforce and Fivetran table and column names based on the attached files. The names can be slightly different. Underscore ("_") can be added or removed. Probably other differences exist. You need to find similarities between the 2 list and output the list of all tables and columns from both files which you can map
```


The Python code created salesforce_fivetran_mapped_columns.csv file and then I used it as mapping.csv seed to create a mapping table.
 install pandas
- pip install pandas
- cd project_setup_utils to run mapping.py
- "C:/Users/KDrogaieva/OneDrive - Learning.com/Development/dbt-master/transformations/.venv/Scripts/python.exe" "c:/Users/KDrogaieva/OneDrive - Learning.com/Development/dbt-master/transformations/dbt/profiles_salesforce_quickstart/project_setup_utils/mapping.py"
- Only pandas is required to be install
- copy and paste in seeds/mapping.csv Make sure the column NAMES are from mapping.csv (no spaces)

- Run dbt seed after

I need to compare populated columns in Account table for districts and schools accounts. "District" and "School" models were created bassed on "Account" models manually.

The final query to analyze profiles is in 

analyses\all_profiles.sql

combines profiles info and Salesforce metadata.