# Working with Late-Binding Views

This project uses Amazon Redshift late-binding views (`bind=False`)
where appropriate. They provide greater deployment flexibility than
standard views but also introduce important considerations for
development and CI/CD.

## Decision: 

In the Learning.com DW project, late-binding views are intended primarily for reporting and presentation-layer models. If an intermediate model is materialized as a late binding view, make sure it does not depend on an object in an other database (source in rawdata or content_delivery_usage database).

## Why Late-Binding Views?

Standard Redshift views maintain strict dependencies on the underlying
objects. During a dbt run, rebuilding an upstream table materialized model causes Redshift
to implicitly drop downstream (dependent) standard views. This
makes standard views unsuitable for frequently rebuilt dbt models and
complicates automated deployments.

Late-binding views avoid this behavior by deferring dependency
validation until query time. They also enable scenarios that standard
views cannot support, including:

-   Referencing objects in another Redshift database.
-   Querying Redshift Spectrum external tables.

For these reasons, late-binding views are often the preferred choice for
reporting models.

## Validation

Unlike standard views, Redshift does **not** validate late-binding views
when they are created. A view can be created successfully even if:

-   A referenced table does not exist.
-   A referenced column has been renamed or removed.
-   An upstream dependency is invalid.

The failure is detected only when the view is queried.

To prevent broken views from reaching production, every late-binding
view must execute the `validate_view()` post-hook immediately after
creation.

``` jinja
{{ config(
    materialized='view',
    bind=False,
    post_hook=['{{ validate_view() }}']
) }}
```

The validation hook performs a simple query against the newly created
view, causing dependency errors to surface during `dbt run` rather than
later in production.

## CI/CD Considerations

This project uses Slim CI/CD (`--defer`) to validate only modified
objects. dbt creates late binding views in QA database based on objects in DW database.

Be aware of an important Redshift limitation:

A late-binding view in QA database **cannot** reference a
deferred late-binding view in DW database when that view itself
depends on objects in a third (rawdata or content_delivery_usage) database.

This is a Redshift limitation, not a dbt limitation.

When this situation occurs, materialize the odel as either as a **table** instead of a late-binding view.

## Design Recommendation

Late-binding views should generally be considered **reporting
endpoints**, not intermediate models in a data pipeline.

Avoid building downstream dbt models that depend on late-binding views
whenever possible. Instead:

-   Use **tables** for intermediate
    transformations.
-   If you use a late-binding view as an intermediate model, make sure it does not depend on an object in an other database (rawdata or     content_delivery_usage source)
-   Reserve late-binding views for exposing curated data to BI tools and
    end users.
-   Keep late-binding views near the end of the dependency graph.

This approach minimizes runtime dependency issues, avoids Slim CI/CD
limitations, and makes deployments significantly more reliable.
