# LCom DW Distribution Key Design

## Overview

Accounts, primarily districts, are central to LCom reporting. For this
reason, warehouse tables containing `account_id` or
`organization_district_id` are generally distributed by that column.

`DIM_ACCOUNT` is the conformed account dimension. Accounts may originate
in Salesforce, LCom Platform, HubSpot, Gainsight, or other systems and
may or may not be integrated with each other.

The intended account key hierarchy is:

    COALESCE(
        LCom Organization ID,
        Salesforce Account ID,
        Gainsight Account ID,
        HubSpot Account ID
    )

Currently, `DIM_ACCOUNT` primarily integrates Salesforce accounts and
LCom Organizations.

### `account_id` and `sfdc_account_id`

`account_id` is the **conformed warehouse account identifier** and
distribution key. Depending on the account integration state, it may
contain either an LCom Organization ID or a Salesforce Account ID.

`DIM_ACCOUNT` also retains `sfdc_account_id` as the stable Salesforce
identifier.

Except for known integration exceptions, `sfdc_account_id` is unique and
safe to use for joins between Salesforce-based warehouse tables. The
exceptions are intentionally identifiable:

-   LCom Organizations not linked to Salesforce have
    `sfdc_account_id = 'Unknown'`.
-   LCom Organizations with an invalid or duplicate Salesforce
    relationship use an `sfdc_account_id` with the `dup-` prefix.

Salesforce-based fact tables should therefore retain both identifiers
where applicable. For example, `FACT_OPPORTUNITY` contains:

-   `account_id` --- the conformed account identifier and distribution
    key; it may be an LCom Organization ID or Salesforce Account ID.
-   `sfdc_account_id` --- the original Salesforce Account ID associated
    with the opportunity.

This allows `account_id` to provide consistent distribution and joins
across the broader warehouse, while `sfdc_account_id` provides a stable
key for joins between Salesforce-derived datasets.

## Why `account_id` Is Not an Immutable Surrogate Key

Large historical usage fact tables already use **LCom Organization ID as
their distribution key**. Rebuilding these tables around a new warehouse
surrogate key would be expensive and provide little practical benefit.

Salesforce data is negligible in size compared with the usage data.
Therefore, the design adapts the smaller account/CRM datasets to the
existing usage-data distribution strategy.

As a result, `DIM_ACCOUNT.account_id` can change during an account's
lifetime.

For example:

1.  An account exists only in Salesforce →
    `account_id = Salesforce Account ID`.
2.  An LCom Organization is created but is not correctly linked to
    Salesforce → two separate `DIM_ACCOUNT` records exist.
3.  The correct Salesforce ID is assigned to the LCom Organization → the
    records are consolidated and `account_id = LCom Organization ID`.

This is intentional. `account_id` represents the **current preferred
conformed account identifier**, not an immutable warehouse surrogate
key.

## `DIM_ACCOUNT` Materialization

`DIM_ACCOUNT` uses dbt `table` materialization.

Most Salesforce accounts receive a new modified timestamp daily even
when meaningful account attributes have not changed. Consequently, an
incremental load processes a large portion of the table and has proven
slower than a full rebuild.

The same approach may be used for other relatively small
Salesforce-based tables where a full reload performs better than
incremental processing.

## Historical Account Key Updates

`account_id` is a `punch_thru_col` in most historical models. If account
identity is resolved differently, historical records are updated to the
new `account_id`.

`DIM_ACCOUNT_HISTORY` requires special handling through the
`DIM_ACCOUNT` post-hook:

    update_DIM_ACCOUNT_HISTORY_changed_UK

The macro uses `sfdc_account_id` to identify historical records whose
current `account_id` differs from `DIM_ACCOUNT.account_id`.

When a Salesforce-only account becomes associated with an LCom
Organization, the macro:

-   identifies the old and new `account_id`;
-   archives conflicting LCom-side history into
    `DIM_ACCOUNT_HISTORY_DELETED`;
-   removes that conflicting history to prevent overlapping account
    histories;
-   updates the remaining historical records to the new LCom
    Organization `account_id`;
-   regenerates `account_hist_id` using the new `account_id` and
    `fromdate`;
-   removes history for Salesforce accounts that no longer exist in the
    Salesforce source.

A companion cleanup removes records where `fromdate = todate`.

## Design Recommendation

The current approach should be retained while the large usage tables
continue to use LCom Organization ID as their distribution key.

New account-related models should:

-   use `account_id` as the distribution key when appropriate;
-   prefer LCom Organization ID when available;
-   retain `sfdc_account_id` in Salesforce-derived models as the stable
    Salesforce account identifier;
-   use `sfdc_account_id` for Salesforce-to-Salesforce joins where
    appropriate, excluding `Unknown` and `dup-` integration exceptions;
-   allow `account_id` to change when cross-system account identity is
    resolved;
-   propagate changed `account_id` values through historical data where
    required;
-   not treat `DIM_ACCOUNT.account_id` as an immutable surrogate key.

This is an intentional trade-off: **controlled key mutation in
relatively small account datasets is preferred over rebuilding and
redistributing very large historical usage datasets.**