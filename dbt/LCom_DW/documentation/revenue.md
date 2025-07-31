{% docs column_revenue_mon_year %}
Month in YYYYMM format, based on invoiced or closed date.
{% enddocs %}

{% docs column_revenue_mon_lastday %}
Last day of the month, based on invoiced or closed date.
{% enddocs %}


{% docs column_renewal_stage_name %}
Stage name of the renewal opportunity (e.g., Closed Won, Closed Lost). Defaults to 'Unknown' if null.
{% enddocs %}

{% docs column_renewal_invoiced_date %}
Invoiced date of the renewal opportunity. Defaults to 1900-01-01 if null.
{% enddocs %}

{% docs column_renewal_close_date %}
Close date of the renewal opportunity.
{% enddocs %}

{% docs column_bucket %}
Revenue category. Can include:  
- Product class from opportunity line ('Sales : Renewal : ARR','Sales : Renewal : Biz Dev','Sales : Renewal : NRR',  
  'Sales : Renewal : Upfront Yr 2&3','Sales : Renewal : Upfront Yrs>3',  
  'Sales : Reseller ARR Renewal','Sales : Reseller ARR Renewal Upfront Yr 2&3',  
  'Sales : Reseller ARR Upsell','Sales : Upsell : ARR','Sales : Upsell : Biz Dev',  
  'Sales : Upsell : NRR','Sales : Upsell : Upfront Yr 2&3',  
  'Sales : Upsell : Upfront Yrs>3','Sales: New Business ARR',  
  'Sales: New Business NRR','Sales: New Business: Upfront yr 2&3',  
  'Sales: Renewal: Upfront Yr 2&3','Sales: Renewal: Upfront Yr >3',  
  'Sales: Renewal:ARR','Sales: Renewal:NRR','Sales: Upsell ARR',  
  'Sales: Upsell NRR','Sales: Upsell: Upfront Yr 2&3')  
- 'Sales : Price Increased : ARR/Biz Dev'  
- 'Sales : Reduction : ARR/Biz Dev'  
- 'Sales : Cancellation : ARR/Biz Dev' for other categories.  
Biz Dev is for State Initiative True
{% enddocs %}

{% docs column_amount %}
Aggregated revenue amount. Comes from:  
- SUM of total_price from opportunity lines for ARR and Booking  
- opportunity price_increase_arr field for price increases (ARR)  
- downsell for reductions (ARR)  
- true_arr_formula for cancellations
{% enddocs %}s

{% docs column_revenue_record_type %}
Revenue record type, e.g., ARR-Starting, ARR-MonthlyAdded, ARR-MonthlyReduced, or MonthlyBooking.
{% enddocs %}


{% docs column_revenue_audit_id %}
Audit identifier used to track record quality. 1 if there is disable_auto_renewal_opp is False but no renewal opportunity and we may not expect renewal
{% enddocs %}

{% docs column_new_opp_this_fy_flg %}
Flag indicating if the opportunity parent or grand parent is "New Business" in the current fiscal year.
{% enddocs %}









