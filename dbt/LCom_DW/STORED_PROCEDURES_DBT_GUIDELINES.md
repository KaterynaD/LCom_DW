# Stored Procedures in dbt Development Guidelines

This project supports stored procedure-based dbt models when they
provide a clear practical benefit.

The goal is to keep stored procedures, target tables, and deployment
logic fully version-controlled and compatible with CI/CD.

## Pattern Overview

A stored procedure-based model consists of three parts:

1.  A macro that defines the target table DDL.
2.  A macro that defines the stored procedure DDL.
3.  A dbt model that executes the stored procedure.

The dbt model should remain small. The table definition and stored
procedure definition belong in reusable macros.

## Table DDL Macro

The table DDL macro defines the physical table only. It should contain
the table definition, distribution style, sort keys and comments, but no
business logic.

``` sql
{% macro create_example_table() %}

{% set custom_schema = deployment_schema() %}

{% set create_table_operation %}

CREATE TABLE IF NOT EXISTS {{ target.database }}.{{ custom_schema }}.example_table
(
    id bigint not null,
    created_date date,
    loaddate timestamp
);

{% endset %}

{{ run_DDL('example_table', create_table_operation) }}

{% endmacro %}
```

`CREATE TABLE IF NOT EXISTS` preserves historical production data while
ensuring the table exists during deployment.

## Stored Procedure DDL Macro

The stored procedure DDL macro contains the procedural SQL.

``` sql
{% macro create_example_procedure() %}

{% set custom_schema = deployment_schema() %}

{% set create_sp_operation %}

CREATE OR REPLACE PROCEDURE {{ target.database }}.{{ custom_schema }}.load_example(ploaddate timestamp)
LANGUAGE plpgsql
AS $$
begin

    delete from {{ target.database }}.{{ custom_schema }}.example_table;

    insert into {{ target.database }}.{{ custom_schema }}.example_table
    select *
    from {{ ref('upstream_model') }};

end;
$$;

{% endset %}

{{ run_DDL('load_example', create_sp_operation) }}

{% endmacro %}
```

`CREATE OR REPLACE PROCEDURE` keeps the database synchronized with the
repository.

## Deployment Schema Macro

Database schemas are configured per dbt model folders.

The `deployment_schema()` macro determines the correct schema for
deployment regardless of whether the DDL is executed from a model or
`dbt run-operation`.



## DDL Execution Macro

The `run_DDL()` macro is the execution gate for DDL statements.

``` sql
{{ run_DDL('example_table', create_table_operation) }}
```

It executes DDL only when deployment mode is enabled (deploy_flag is True in CI/CD only but not regular nightly pipeline) and when there is a dbt model run  (or build) or macro run-operation performs.

## dbt Model

The model orchestrates deployment and execution.

``` sql
{{ config(
    materialized='sql_runner',
    pre_hook=[
        '{{ create_example_table() }}',
        '{{ create_example_procedure() }}'
    ]
) }}

-- depends_on: {{ ref("dim_calendar") }}
-- depends_on: {{ source("dbo","fact_assignment_launch") }}

call {{ target.database }}.{{ schema }}.load_example(
    cast('{{ var("loaddate") }}' as timestamp)
);
```

## Why `depends_on` Comments Matter

Stored procedures frequently reference **upstream dependencies** inside
macro-generated SQL.

Because dbt cannot always discover those references automatically,
declare every upstream model or source in the dbt model using
`depends_on` comments.

This ensures:

-   correct DAG generation;
-   accurate lineage;
-   proper Slim CI/CD selection;
-   correct `state:modified+` behavior;
-   easier code reviews.

## Future Development

Introduce a standard dry-run parameter for all stored procedures.

The deployment framework should translate the dbt `--empty` flag into this parameter during CI/CD validation. In dry-run mode, stored procedures should validate SQL, object dependencies, and execution plans without modifying data. This provides lightweight validation while preserving the behavior of normal production runs.

## CI/CD

The pattern allows create missing tables and stored procedures during CI/CD in QA database and replace stored procedures only  in DW database.

deployment_pre_tasks and deployment_post_tasks models can be used for more complex operations like alter table to add a new column and populate historical data.

## Deployment Rules

-   Store all DDL in macros.
-   Keep the dbt model small.
-   Use `CREATE TABLE IF NOT EXISTS` for tables.
-   Use `CREATE OR REPLACE PROCEDURE` for stored procedures.
-   Use `deploy_flag=True` only during CI/CD deployments.
-   Declare all upstream dependencies with `depends_on` comments.
-   Never modify or deploy production objects manually.

## Summary

This pattern treats stored procedures as first-class dbt assets while
keeping deployments deterministic, version-controlled, and compatible
with Slim CI/CD.
