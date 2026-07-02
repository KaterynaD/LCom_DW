# Working with Late-Binding Views

This project uses Amazon Redshift late-binding views (`bind=False`)
where appropriate. They provide greater deployment flexibility than
standard views but also introduce important considerations for
development and CI/CD.

## Decision: 

In the Learning.com DW project, late-binding views are intended primarily for reporting and presentation-layer models. Intermediate models should be materialized as tables or materialized views unless there is a documented reason to do otherwise.

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
depends on objects in a third (rawdata) database.

This is a Redshift limitation, not a dbt limitation.

When this situation occurs, materialize the upstream model as either:

-   A **table**, or
-   A **materialized view**,

instead of a late-binding view.

## Design Recommendation

Late-binding views should generally be considered **reporting
endpoints**, not intermediate models in a data pipeline.

Avoid building downstream dbt models that depend on late-binding views
whenever possible. Instead:

-   Use **tables** or **materialized views** for intermediate
    transformations.
-   Reserve late-binding views for exposing curated data to BI tools and
    end users.
-   Keep late-binding views near the end of the dependency graph.

This approach minimizes runtime dependency issues, avoids Slim CI/CD
limitations, and makes deployments significantly more reliable.

## Summary

-   Prefer **tables** or **materialized views** for reusable upstream
    models.
-   Use late-binding views primarily as reporting or presentation-layer
    objects.
-   Always configure `bind=False` together with the `validate_view()`
    post-hook.
-   Never assume a successfully created late-binding view is valid until
    it has been queried.
-   Consider late-binding views as **pipeline endpoints, not pipeline
    building blocks**.
