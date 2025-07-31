{% docs column_loaddate %}
The datetime the record was loaded in PST
{% enddocs %}

{% docs column_fiscalyear %}
Fiscal year in YYYY/YYYY format e.g. 2024/2025.
{% enddocs %}

{% docs column_fiscalyear_mon %}
Fiscal year-month number
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
Salesforce Account ID for the opportunity.
{% enddocs %}

{% docs column_sfdc_state_initiative %}
Boolean indicating if account is part of a state initiative.
{% enddocs %}

{% docs column_sfdc_ultimate_parent_id %}
Salesforce ID of the ultimate parent account.
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