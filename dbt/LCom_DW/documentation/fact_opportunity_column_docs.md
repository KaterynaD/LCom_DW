{% docs column_opportnity_name %}
Opportunity Name
{% enddocs %}

{% docs column_opportunity_amount %}
Amount
{% enddocs %}

{% docs column_amount_won %}
Amount Won
{% enddocs %}

{% docs column_arr_bands %}
ARR Bands
{% enddocs %}

{% docs column_arr %}
ARR (implemented to capture ARR value of opportunity)
{% enddocs %}

{% docs column_arr_new_business %}
ARR New Business (ARR New Business)
{% enddocs %}

{% docs column_arr_renewal %}
ARR Renewal (ARR renewal)
{% enddocs %}

{% docs column_arr_upsell %}
ARR Upsell (ARR Upsell)
{% enddocs %}

{% docs column_arr_won %}
ARR Won
{% enddocs %}

{% docs column_billing_addressee %}
Billing Addressee (Billing Addressee)
{% enddocs %}

{% docs column_billing_city %}
Billing City (Billing City)
{% enddocs %}

{% docs column_billing_state %}
Billing State (Billing State)
{% enddocs %}

{% docs column_billing_street %}
Billing Street (Billing Street)
{% enddocs %}

{% docs column_billing_zipcode %}
Billing Zipcode (Billing Zipcode)
{% enddocs %}

{% docs column_churn_date %}
Churn Date
{% enddocs %}

{% docs column_churn_formula %}
Churn (Formula) (If the opportunity is lost will calculate a negative value for churn)
{% enddocs %}

{% docs column_combined_arr %}
Combined ARR
{% enddocs %}

{% docs column_contract_id %}
Contracts
{% enddocs %}


{% docs column_loss_reason %}
Closed (Won or Lost)  Reason 
{% enddocs %}

{% docs column_loss_notes %}
Closed (Won or Lost)  Notes
{% enddocs %}

{% docs column_multi_year_arr %}
Multi-Year ARR (Roll up summary of all opporunity products with Class of ARR for creating multi-year calculations)
{% enddocs %}

{% docs column_multi_year_order %}
Multi Year Upfront Order?
{% enddocs %}

{% docs column_new_biz_arr_trigger %}
New Biz ARR Trigger
{% enddocs %}

{% docs column_nnarr %}
NNARR (Calculates the change in ARR from the previous contract)
{% enddocs %}

{% docs column_nrr_renewal %}
NRR Renewal
{% enddocs %}

{% docs column_number_of_schools %}
Number of Schools
{% enddocs %}

{% docs column_number_of_students %}
Number of Students
{% enddocs %}

{% docs column_opportunity_number %}
Opportunity Number - not available in SFDC as on 10/21/2025. Number__c SFDC Object attribute is used instead since opportunity_number column name is already widely used including Tableau and hard to fix everywhere.
{% enddocs %}

{% docs column_opportunity_score_id %}
Opportunity Score
{% enddocs %}

{% docs column_original_close_date %}
Original Close Date (Original Close Date of Opp)
{% enddocs %}

{% docs column_paid_date %}
Paid Date
{% enddocs %}

{% docs column_payment_terms %}
Payment Terms (Payment term)
{% enddocs %}

{% docs column_po_amount %}
PO Amount (PO Amount)
{% enddocs %}

{% docs column_price_increase_arr %}
Price Increase ARR
{% enddocs %}

{% docs column_pricebook_2_id %}
Price Book
{% enddocs %}

{% docs column_primary_quote_approved %}
Primary Quote approved (Primary Quote approved checked if status is approved)
{% enddocs %}

{% docs column_probability %}
Probability (%)
{% enddocs %}

{% docs column_progressive_billing %}
Progressive Billing
{% enddocs %}

{% docs column_progressive_payment_amount_2 %}
Progressive Payment Amount 2
{% enddocs %}
{% docs column_progressive_payment_amount_3 %}
Progressive Payment Amount 3
{% enddocs %}    
{% docs column_progressive_payment_amount_4 %}
Progressive Payment Amount 4
{% enddocs %}    
{% docs column_progressive_payment_amount_5 %}
Progressive Payment Amount 5
{% enddocs %}    
{% docs column_progressive_payment_date_2 %}
Progressive Payment Date 2
{% enddocs %}    
{% docs column_progressive_payment_date_3 %}
Progressive Payment Date 3
{% enddocs %}    
{% docs column_progressive_payment_date_4 %}
Progressive Payment Date 4
{% enddocs %}    
{% docs column_progressive_payment_date_5   %}
Progressive Payment Date 5s
{% enddocs %}    





{% docs column_quota %}
Quota
{% enddocs %}

{% docs column_quote_contract_type %}
Quote Contract Type
{% enddocs %}

{% docs column_quote_created_date %}
Quote created Date
{% enddocs %}

{% docs column_quote_expiry_date %}
Quote Expiry Date
{% enddocs %}

{% docs column_quote_list_amount %}
Quote List Amount
{% enddocs %}

{% docs column_quote_name %}
Quote name
{% enddocs %}

{% docs column_quote_notes %}
Quote Notes (Quote Notes)
{% enddocs %}

{% docs column_quote_start_date %}
Quote Start Date
{% enddocs %}

{% docs column_renewable_revenue %}
Renewable Revenue
{% enddocs %}



{% docs column_school_list %}
School List
{% enddocs %}

{% docs column_source_opp_arr %}
Source Opp ARR (ARR from account's most recent Closed Won Opportunity)
{% enddocs %}

{% docs column_total_arr_bookings %}
Total ARR Bookings (Captures renewal ARR + Upsell ARR)
{% enddocs %}

{% docs column_true_arr %}
True ARR (Denotes the true ARR value of an opportunity.  Populated by a scheduled flow to allow for roll-up summary to be used on the account object to report on true ARR)
{% enddocs %}

{% docs column_true_arr_formula %}
True ARR (Formula) (Looks at Override ARR and if that field is greater than zero, returns Override, else returns Source Opp ARR from previous contract)
{% enddocs %}

{% docs column_true_renewal_arr %}
True Renewal ARR
{% enddocs %}

{% docs column_x_1_st_contact %}
1st Contact
{% enddocs %}

{% docs column_x_1_st_contact_email %}
1st Contact Email
{% enddocs %}

{% docs column_x_1_st_contact_name %}
1st Contact Name
{% enddocs %}

{% docs column_x_1_st_contact_role %}
1st Contact Role
{% enddocs %}

{% docs column_x_2_nd_contact %}
2nd Contact
{% enddocs %}

{% docs column_x_2_nd_contact_email %}
2nd Contact Email
{% enddocs %}

{% docs column_x_2_nd_contact_name %}
2nd Contact Name
{% enddocs %}

{% docs column_x_3_rd_contact %}
3rd Contact
{% enddocs %}

{% docs column_x_3_rd_contact_email %}
3rd Contact Email
{% enddocs %}

{% docs column_x_3_rd_contact_name %}
3rd Contact Name
{% enddocs %}

{% docs column_downsell %}
Downsell (Automatically derives downsell)
{% enddocs %}

{% docs column_multi_year_discount_rate %}
Multi-Year Discount. It's visible to quote managers on their layout.
There is no evidence that it's directly fed into total discount at the quote line / opportunity product line level.
• Customers with a Paid-up-front contract receive: 
	-- 10% discount when the subscription term is between 24 and 35 months. 
	-- 15% discount when the subscription term is 36 months or longer. 
• Customers with a Progressive contract receive: 
	--5% discount when the subscription term is between 24 and 35 months. 
	-- 10% discount when the subscription term is 36 months or longer. 
• No discount is applied for: 
	-- Subscription terms shorter than 24 months, or 
Contract types other than Paid-up-front or Progressive.
{% enddocs %}

{% docs column_license_provisioned_date %}
License Provisioned Date
{% enddocs %}

{% docs column_sbqq_primary_quote %}
Primary Quote (Points to primary quote on this opportunity.)
{% enddocs %}

{% docs column_subscription_end_date %}
Subscription End Date (Subscription End Date)
{% enddocs %}

{% docs column_subscription_start_date %}
Subscription Start Date (Subscription Start Date)
{% enddocs %}

{% docs column_subscription_term %}
Total Subscription term for a Progressive opportunity. It can be different then End Date - Start Date if there is a commitment to pay for few next years. progressive_billing is true "PROG" is in the name of the opportunity
{% enddocs %}

{% docs column_Override_ARR %}
ARR used as interim value when source opp ARR is not present due to no contract history.  Used in opps that were imported from NS at SF go live.  Should be deprecated by end of 2023. But it's still in active use as of May 2026 active opportunities
{% enddocs %}


Override_ARR