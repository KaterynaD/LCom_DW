# dbt materialization: `sfdc_history_scd2`

A dbt custom materialization that turns a Salesforce `*_History` table (field-level change log) into a **compact Slowly Changing Dimension Type 2 (SCD2)** table.

It is designed for one-time (or occasional) *history backfill* from Salesforce History tables and produces an analytics-friendly SCD2 structure with validity windows.

---

## What this materialization does

Given a model query that returns **history events** (at minimum):

- `unique_key` — object id (e.g., `contact_id`)
- `created_date` — when the change event happened
- `field` — which attribute changed (Salesforce History `Field`)
- `old_value`
- `new_value`
- *(optional but commonly present)* `data_type` — Salesforce History `DataType`

…this materialization builds:

- One row per object per “version”
- `fromdate` / `todate` validity windows
- `record_version` (1..n)
- `hist_id` (md5 of `unique_key + fromdate`)
- `scd_hash` (md5 of tracked attribute values)

e.g. 

- Reconstructs full attribute history
- Handles daily deduplication
- Backfills initial values from a base dimension/source
- Builds non-overlapping SCD2 intervals
- Collapses identical adjacent segments
- Produces deterministic, reproducible SCD2 output

Designed specifically for Salesforce history tables, but can be adapted to other systems with similar structure.

---

## Important limitation (read this)

- Salesforce History is **field-level** and typically does not store the full record state for every moment in time.
This materialization reconstructs history only for the attributes you list in `fields_config`.
- old and new values are always varchar(string) even if a date or numeric value is inside and the data type is not converted from string to date or number in this materialization

If you want the *complete* current state (including attributes that never changed), you should provide a base relation (either a dbt model or a dbt source). See **Base relation reconstruction** below.

You can convert the history table into a staging SCD2 alike table and convert the data types when loading into working SCD2 table.

---
## What Problem This Solves

Salesforce history tables:
- Only store changed fields
- Only store changed values
- Do NOT store initial state
- May store multiple changes within the same day
- May store redundant changes across consecutive days

This materialization reconstructs:

- Full attribute timeline
- Proper SCD2 validity intervals
- One change per day per attribute
- Correct handling of never-changed attributes
---

## Installation

1. Put the materialization macro in your project, e.g.
   - `macros/materializations/sfdc_history_scd2.sql`

2. Create a model that selects from your History table and configures the materialization.

---

## Configuration reference

### SQL

Your model SQL must return at least:

```SQL
object_unique_id   -- e.g. contact_id, account_id
created_date       -- timestamp of change
field              -- name of changed field
data_type          -- Salesforce data type
new_value
old_value
```
Example:

```SQL
select
    contact_id,
    created_date,
    field,
    data_type,
    new_value,
    old_value
from fivetran_salesforce.contact_history
```

### Required configs

All configuration is passed via config() block.

#### `materialization` (string)

Example:
```yaml
materialized = "sfdc_history_scd2"
```
Required.

#### `unique_key` (string)
Name of the identifier column coming from your history query.

Example:
```yaml
unique_key = "contact_id"
```

#### `fields_config` (list of dict)
Defines which history fields to track and how to map them to output columns.

Each item supports:

- `source_field` *(required)*: exact Salesforce History `field` value
- `type` *(optional)*: expected Salesforce History `data_type` (required when the same `field` name appears with different data types)
- `target_field` *(optional)*: output column name  and column name from the base relation if it's used (defaults to `source_field`)
- `default` *(optional but highly recommended)*: default used when base value is null or when a field has never been set

Example:
```yaml
fields_config = [
    {
        "source_field": "lead_Status__c",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "lead_status"
    },
    {
        "source_field": "Account",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "sfdc_account_id"
    },
    {
        "source_field": "Owner",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "owner_id"
    },
    {
        "source_field": "MailingStateCode",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "mailing_state_code"
    }
]
```

### Optional, but highly recommended configs (defaults)

- `first_fromdate` *(default: `'1900-01-01'`)*
- `last_todate` *(default: `'3000-12-31'`)*


first_fromdate defines:

- Start of history
- Bootstrap timestamp

last_todate used for:

- Open-ended records
- Final SCD interval

```yaml
first_fromdate="1900-01-01",
last_todate="3000-12-31",
```

### Base relation reconstruction (recommended)

To ensure you get SCD2 rows for objects/attributes that **never changed in history**, provide **ONE** of:

- `base_model` (string): dbt model name (e.g., `dim_contact`)
- `base_source` (dict): `{"name": "<source_name>", "table": "<table_name>"}` (e.g., the raw `contact` table)

Additional optional but required if different from `unique_key` base-related config:
- `base_unique_key` (string, default = `unique_key`) — the id column in the base relation (e.g., Salesforce `contact.id`)

**Important dbt dependency note**

Because `base_model` / `base_source` are read via `config()` (not via `ref()`/`source()` in SQL),
you must add a `-- depends_on:` hint in the model SQL so dbt builds the dependency graph correctly.

Examples:

```yaml
base_model="dim_contact"
```

```sql
-- depends_on: { ref('dim_contact') }
```

```yaml
unique_key='contact_id',
base_source = {'name': 'fivetran_salesforce_quickstart', 'table': 'contact'},
base_unique_key='id',
```

```sql
-- depends_on: { source('fivetran_salesforce_quickstart','contact') }
```

---

## Output columns (high level)

Your output table includes (names may vary based on your `target_field` mappings):

- `hist_id`
- `fromdate`
- `todate`
- `record_version`
- `{{ unique_key }}`
- one column per tracked attribute (mapped from `fields_config`)
- `scd_hash`

---
# Processing Logic (Step-by-Step)

## 1.Filter Relevant History Records

- Only configured fields
- Only matching data_type
- Ignore redundant rows (old_value != new_value)

## 2. Identify First Change per Field
Find earliest change for each unique_key and filed

## 3. Bootstrap Initial History
Two cases:

### Case A — Attribute Was Changed

Use old_value from first change.

### Case B — Attribute Never Changed

Take value from base_relation if configured.

All start at first_fromdate.

## 4. Daily Deduplication
If multiple changes happen in same day:

- Keep only latest timestamp per day
- Ignore intermediate changes

## 5. Skip Redundant Consecutive Days
If:

```
Day 1 → A (possible interday changes to B, C,D but ended with A)
Day 2 → A (possible interday changes to B, C,D but ended with A)
Day 3 → A (possible interday changes to B, C,D but ended with A)
```
Only one interval is created.
---
## 6. Build Attribute-Level SCD2

Each field independently becomes:

```
unique_key
fromdate
todate
value
```
## 7. Build Global Time Boundaries
Union all from/to dates across all attributes.

Generate minimal non-overlapping intervals.

## 8. Stitch Attributes Togethe
For each interval:

Find attribute value covering that start date.

## 9. Collapse Identical Adjacent Rows
If no attribute changed:

Merge intervals.

## 10. Final Output
Output contains:

- Surrogate key
- fromdate
- todate
- record_version
- unique_key
- All configured attributes
- Hash of attribute values
- Load metadata

# Examples

Below are 3 demo models + their compiled SQL (including DDL) + sample output rows.

## Example 1 — Minimal config (no base relation)

**Use when:** you only want the SCD2 history for objects that appear in the history table, and you accept that objects/fields that never changed may be absent.

### Model SQL (`sfdc_contact_history_to_scd2_min_config.sql`)
```sql
{{ config(
    materialized='sfdc_history_scd2',
    unique_key='contact_id',
    fields_config = [
    {
        "source_field": "lead_Status__c"
    },
    {
        "source_field": "MailingStateCode"
    }
]
) }}



select
contact_id,
created_date,
field,
data_type,
new_value,
old_value
from {{ source('fivetran_salesforce_quickstart', 'contact_history') }}


```



---

## Example 2 — Add never-changed objects from a dbt model (`base_model='dim_contact'`)

**Use when:** you already have a curated/clean `dim_contact` (or similar) model and you want:
- objects with **no history** to still appear in the result
- defaults + renames + optional `data_type` filtering

### Model SQL (`sfdc_contact_history_to_scd2.sql`)
```sql
{{ config(
    materialized='sfdc_history_scd2',
    unique_key='contact_id',
    base_model='dim_contact',
    first_fromdate='1900-01-01',
    last_todate='3000-12-31',
    fields_config = [
    {
        "source_field": "lead_Status__c",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "lead_status"
    },
    {
        "source_field": "Account",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "sfdc_account_id"
    },
    {
        "source_field": "Owner",
        "type": "EntityId",
        "default": "00000000-0000-0000-0000-000000000000",
        "target_field": "owner_id"
    },
    {
        "source_field": "MailingStateCode",
        "type": "DynamicEnum",
        "default": "Unknown",
        "target_field": "mailing_state_code"
    }
]
) }}

-- depends_on: {{ ref('dim_contact') }}


select
contact_id,
created_date,
field,
data_type,
new_value,
old_value
from {{ source('fivetran_salesforce_quickstart', 'contact_history') }}

```

---

## Example 3 — Add never-changed objects from a dbt source (`base_source` = raw `contact`)

**Use when:** you want to reconstruct SCD2 using the raw Salesforce object table as the base (for objects/fields that never changed).

### Model SQL (`sfdc_contact_and_contact_history_to_scd2.sql`)
```sql
{{ config(
    materialized='sfdc_history_scd2',
    unique_key='contact_id',
    base_source = {'name': 'fivetran_salesforce_quickstart', 'table': 'contact'},
    base_unique_key='id',
    first_fromdate='1900-01-01',
    last_todate='3000-12-31',
    fields_config = [
    {
        "source_field": "lead_Status__c",
        "default": "Unknown",
        "target_field": "lead_status_c"
    },
    {
        "source_field": "MailingStateCode",
        "default": "Unknown",
        "target_field": "mailing_state_code"
    }
]
) }}

-- depends_on: {{ source('fivetran_salesforce_quickstart','contact') }}

select
contact_id,
created_date,
field,
data_type,
new_value,
old_value
from {{ source('fivetran_salesforce_quickstart', 'contact_history') }}


```

---

# Key differences between the 3 examples

### 1) Minimal config (no base)
- ✅ simplest configuration
- ✅ fastest to get working
- ❌ missing objects that never had a history row
- ❌ missing fields that never changed (they may appear as null/empty depending on history availability)

### 2) `base_model='dim_contact'`
- ✅ brings in never-changed objects (from `dim_contact`)
- ✅ supports strong typing and curated business logic from your dimension model
- ✅ supports `type` filtering in `fields_config`
- ✅ ideal when you already have a trusted “base” dimension table

### 3) `base_source={name, table}` (raw source)
- ✅ brings in never-changed objects from the raw Salesforce object table
- ✅ avoids dependency on an existing curated dimension model
- ✅ good for first-time backfills / migrations
- ⚠️ you may need extra cleansing in downstream models

---

## Recommended operational pattern
For many teams, Salesforce History backfill is best treated as a **one-time load**:
1. Use `sfdc_history_scd2` to create a compact SCD2 history table.
2. Then keep a *forward-only* SCD2 table maintained with a snapshot/materialization designed for incremental loads
   (for example, using `dbt_scd2_plus` approach), instead of continuously re-processing Salesforce History tables.

---
## Performance Considerations
Recommended for:
- Moderate history volume
- Attribute count under ~25 fields
---
## Notes
- Target is always created/replaced as a **TABLE** (drops if exists).
- Only fields listed in `fields_config` are tracked.
- If you care about “who changed it” (`created_by_id` in Salesforce History):
  - that information is present per change event in the history table,
  - but it is not represented as a stable attribute for the entire validity window in an SCD2 row unless you explicitly model it.
  

