{{ config(materialized='ephemeral') }}


select
order_id,
sku_id,
organization_district_id,
startdate,
expirationdate,
enforcedaterestrictions,
netsuite_order_id,
valid,
SchoolCount, 
StudentCount,
auditupdatedate
from {{ ref("fact_license_order") }}
