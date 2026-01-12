{% docs column_loaddate %}
The datetime the record was loaded in PST
{% enddocs %}

{% docs column_mon_year %}
Reporting Month and Year in the form YYYYMM (the data are in the reported state at the end of this Year and Month)
{% enddocs %}

{% docs column_mon_lastday %}
Reporting Month last date (the data are in the reported state at the date)
{% enddocs %}


{% docs column_fiscalyear %}
Fiscal year in YYYY/YYYY format e.g. 2024/2025.
{% enddocs %}

{% docs column_fiscalyear_mon %}
Fiscal year-month number
{% enddocs %}


{% docs column_schoolyear %}
School year in YYYY/YYYY format e.g. 2024/2025.
{% enddocs %}

{% docs column_schoolyear_mon %}
School year-month number
{% enddocs %}

{% docs column_include_flg %}
Flag indicating whether the record should be included in the calculation.
{% enddocs %}



{% docs column_opportunity_id %}
Unique Salesforce opportunity ID.
{% enddocs %}

{% docs column_stage_name %}
Stage of the opportunity (e.g., Closed Won, Closed Lost).
{% enddocs %}

{% docs column_opp_record_type %}
Type of opportunity, such as New, Renewal, or Upsell.
{% enddocs %}

{% docs column_sfdc_account_id %}
Salesforce Account ID.
{% enddocs %}


{% docs column_invoiced_date %}
Invoice date of the opportunity. Defaults to 1900-01-01 if null (cancellations).
{% enddocs %}

{% docs column_close_date %}
Date the opportunity was closed (won or lost).
{% enddocs %}

{% docs column_start_date %}
Start date of the opportunity contract.
{% enddocs %}

{% docs column_end_date %}
End date of the opportunity contract.
{% enddocs %}

{% docs column_renewal_opportunity_id %}
Opportunity ID of the renewal record (if any).
{% enddocs %}

{% docs column_disable_auto_renewal_opp %}
Flag indicating whether auto-renewal was disabled on the opportunity.
{% enddocs %}

{% docs column_license_unenforced %}
Boolean indicating if the license is unenforced.
{% enddocs %}

{% docs column_created_by_id %}
Created By user. The ID allows to join COMMON.DIM_EMPLOYEE, but no FK is created. Can be used for validation purposes
{% enddocs %}

{% docs column_created_date %}
Created Date in PST
{% enddocs %}

{% docs column_last_modified_by_id %}
Last Modified By user. The ID allows to join COMMON.DIM_EMPLOYEE, but no FK is created. Can be used for validation purposes
{% enddocs %}

{% docs column_last_modified_date %}
The datetime the record was loaded in PST
{% enddocs %}

{% docs column_account_id %}
DIM_ACCOUNT PK/FK 
{% enddocs %}

{% docs column_opportunity_line_id %}
DIM_OPPORTUNITY_LINE PK/FK 
{% enddocs %}


{% docs column_owner_id %}
DIM_EMPLOYEE FK
{% enddocs %}

{% docs column_fromdate %}
State of data valid from this date
{% enddocs %}

{% docs column_todate %}
State of data valid to this date
{% enddocs %}

{% docs column_record_version %}
State of data version
{% enddocs %}


{% docs column_updatedate %}
Data updated at in PST
{% enddocs %}


{% docs column_scd_hash %}
Hash of checked columns  to identify changes
{% enddocs %}   

{% docs column_description %}
Description
{% enddocs %}

{% docs column_is_active %}
Flag indicating whether the entity is active
{% enddocs %}

{% docs column_netsuite_id %}
Netsuite ID (integration from Netsuite.)
{% enddocs %}

{% docs column_sfdc_product_id %}
Foreighn Key to DIM_SFDC_Product. Salesforce product
{% enddocs %}

{% docs column_is_closed %}
Closed
{% enddocs %}

{% docs column_po_number %}
PO Number
{% enddocs %}