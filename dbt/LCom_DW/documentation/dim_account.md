{% docs table_dim_account %}


# DIM_ACCOUNT

Conformed DIM_ACCOUNT dimension. Account (districts and schools) data from all source systems.

## Primary and Distribution Key

![Accounts can be created in HubSpot, Salesforce, LCom Platform or any
other source and imported/integrated between the systems or
not.](assets/accounts_created_in_different%20systems.png)

Accounts can be created in Salesforce, LCom Platform, HubSpot, or other source systems and may or may not be integrated
between them.

`DIM_ACCOUNT` is the **conformed account dimension**. It is designed to
combine accounts from different source systems into a single record when
a reliable relationship between them can be established.

`DIM_ACCOUNT` provides a conformed three-level hierarchy of account_id → conformed_district_id → conformed_customer_id across Salesforce and LCom Platform. The hierarchy uses the LCom organization hierarchy to determine the district/intermediate parent when available, because licenses and usage are organized by LCom district and school relationships. For accounts without an LCom hierarchy, the Salesforce account hierarchy is used to determine the intermediate parent. The customer level is determined from the Salesforce Ultimate Parent hierarchy when available; otherwise the conformed district is treated as the customer. An account may itself represent a school, district, or customer level, so account_id, conformed_district_id, and conformed_customer_id may intentionally contain the same value. This structure allows revenue, licenses, and usage recorded at different account levels to roll up consistently without reallocating facts between hierarchy levels.

![DIM_ACCOUNT is designed to join accounts from different systems into a
single record when
possible.](assets/dim_account_populated%20withaccounts_from-different_systems.png)

### `account_id`

`account_id` is the **primary key and Redshift distribution key** of
`DIM_ACCOUNT`.

The preferred identifier follows this hierarchy:

``` text
COALESCE(
    LCom Organization ID,
    Salesforce Account ID,
    Gainsight Account ID,
    HubSpot Account ID
)
```

Currently, `DIM_ACCOUNT` primarily integrates Salesforce Accounts and
LCom Organizations.

The LCom Organization ID has the highest priority because large
historical usage fact tables already use it as their distribution key.
Rebuilding and redistributing these tables around a newly introduced
warehouse surrogate key would be prohibitively expensive compared with
the relatively small Salesforce datasets.

As a result, `account_id` is intentionally **not an immutable surrogate
key**. It represents the current preferred conformed account identifier
and can change during the lifetime of an account.

For example:

1.  A new account exists only in Salesforce →
    `account_id = Salesforce Account ID`.
2.  A corresponding LCom Organization is created → its
    `account_id = LCom Organization ID`.
3.  If the LCom Organization has no Salesforce ID, or the relationship
    is incorrect, the two accounts remain as separate `DIM_ACCOUNT`
    records.
4.  When the correct Salesforce ID is assigned to the LCom Organization,
    the records are consolidated and `account_id` becomes the **LCom
    Organization ID**.

This is an intentional design trade-off: controlled changes to account
keys in relatively small account datasets are preferred over rebuilding
and redistributing very large historical usage datasets.

### `sfdc_account_id`

`DIM_ACCOUNT` also retains `sfdc_account_id` as the stable Salesforce
account identifier.

For correctly integrated accounts, `sfdc_account_id` is unique and can
safely be used to join `DIM_ACCOUNT` with Salesforce-derived tables such
as `FACT_OPPORTUNITY`.

Known integration exceptions are explicitly identifiable:

-   LCom Organizations not linked to Salesforce use
    `sfdc_account_id = 'Unknown'`.
-   LCom Organizations with an invalid or duplicate Salesforce
    relationship use an `sfdc_account_id` with the `dup-` prefix.

Salesforce-derived fact tables therefore generally retain both keys:

-   `account_id` --- conformed account identifier and distribution key;
    may contain either an LCom Organization ID or Salesforce Account ID.
-   `sfdc_account_id` --- Salesforce Account ID used for reliable joins
    between Salesforce-derived datasets.

### Materialization

`DIM_ACCOUNT` uses dbt **`table` materialization** rather than
incremental materialization.

Most Salesforce Accounts receive an updated modified timestamp daily,
even when no meaningful account attributes have changed. As a result,
incremental processing includes a large portion of the source and has
proven slower than a full rebuild of this relatively small dimension.

### Historical Key Changes

Because `account_id` can change when account identity is resolved, it is
configured as a `punch_thru_col` in most related historical models.
Historical records are updated to the current conformed `account_id`.

`DIM_ACCOUNT_HISTORY` requires additional reconciliation, implemented by
the `DIM_ACCOUNT` post-hook:

``` text
update_DIM_ACCOUNT_HISTORY_changed_UK
```

Using `sfdc_account_id` as the stable Salesforce relationship, the
post-hook:

-   identifies historical records where `account_id` has changed;
-   archives conflicting LCom-side history in
    `DIM_ACCOUNT_HISTORY_DELETED`;
-   removes conflicting history before consolidation;
-   updates historical records to the current `DIM_ACCOUNT.account_id`;
-   regenerates `account_hist_id` using the new `account_id` and
    `fromdate`;
-   removes history for Salesforce accounts no longer present in the
    source.

Records where `fromdate = todate` are removed by the companion cleanup
logic.

### Source Column Naming

Source-specific attributes use prefixes to make their origin explicit:

-   `lcom_` --- attributes originating from the LCom Organization data.
-   `sfdc_` --- attributes originating from the Salesforce Account
    object.

Therefore, consumers should treat `account_id` as the **current
conformed account key**, while `sfdc_account_id` should be used when a
stable Salesforce-specific account relationship is required.

## Duplicates:

It's up to the source system to clean duplicates, whatever processes exist.
But there are cases, when more then one LCom Organization IDs are linked to the same Salesforce Id.

In this case:
1. account_id (PK) is unique . It's LCom Organization Id.
2. lcom_organization_id is unique. It's LCom Organization Id. (If not take into account "Unknown" values from salesforce accounts not linked to LCom Organization)
3. sfdc_account_id is NOT unique. However, to make it's cleaner I add "dup-" prefix to all but one Salesforce IDs. If there is a district and school LCom Organization have the same Salesforce Id, then a "district" LCom org record will have "clean" Salesforce Id in sfdc_account_id and "school" LCom org  record will have "dup-" prefix in sfdc_account_id. **In this way, "clean" sfdc_account_id (without "dup" prefix) are unique.**

- It's possible to have more then one sfdc_account_id with the same Salesforce Id starting from "dup-" if there are more then one duplicate Salesforce IDs in LCom Organization. 

- If there are no "district" in LCom Org Salesforce Id duplicates, then a random school is selected as "primary" to have "clean" sfdc_account_id.
- If there are more then one "district" in LCom Org Salesforce Id duplicates, then a random district is selected as "primary" to have "clean" sfdc_account_id.

There is LCOM_SFDC_ACCOUNT_MAPPING table in Staging were the described rules are applied and then used in DIM_ACCOUNT transformation.

Most likely, they are "valid" duplicates in LCom Org Salesforce Id. Probably a multi-level account hierarchy in Salesforce is flatten to"district"-"school" levels.

All "SFDC_*" columns in such records are the same as in the "clean" sfdc_account_id. 

## Default

There is one and only one default record in DIM_ACCOUNT. It has account_id (PK) equal "default_ID" which is "00000000-0000-0000-0000-000000000000". It's used if a transformation can not find a corresponding account in DIM_ACCOUNT for whatever reason.

There are no null values in DIM_ACCOUNT (as in all othe dim and fact tables). They are all replaced with default values like "Unknown" or "1900-01-01" etc.
Be aware when you run something like a recursive or hierarchical queries and expect "NULL" ina  parent account as an example.

{% enddocs %}