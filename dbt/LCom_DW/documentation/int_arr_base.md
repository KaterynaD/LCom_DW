{% docs table_int_arr_base %}
# **Business Logic Overview**

This model standardizes contract timing across ARR types, prevents overlap between contracts, assigns records to reporting months based on adjusted dates, and generates additional rows required for downstream ARR calculations.

---

# **True ARR**

### **Dates**
- **Start Date**
  - Closed Won → use **invoice date** if it is later than the contract start  
  - Closed Lost → use **close date** if it is later than the contract start  

- **Renewal Start Date**
  - Closed Won → use **renewal invoice date** if later  
  - Closed Lost → use **renewal close date** if later  

- **Parent → Renewal (Overlap Prevention)**
  - If renewal starts before the previous contract ends → shift to  
    **day after the latest parent contract ends**  
  - Ensures there is **no overlap between parent and renewal ARR periods**

- **Missing Renewal Start**
  - Set to **day after contract end**

- **Month Assignment**
  - Month is assigned based on the **adjusted Start Date**

---

# **Preliminary ARR**

### **Dates**
- **Start Date**
  - Closed Won → use **invoice date** if later than contract start  
  - Closed Lost → use **close date** if later than contract start  

- **End Date (extended)**
  - Business Development deals → **+6 months**  
  - Texas deals → **+90 days**  
  - All other deals → **+60 days**  

- **End Date Cutoff**
  - If renewal closes or invoices earlier → use that earlier date  

- **Parent → Renewal (Overlap Prevention)**
  - If renewal starts before previous contract ends → shift to  
    **day after the latest parent contract ends**  
  - Ensures there is **no overlap between parent and renewal ARR periods**

- **Missing Renewal Start**
  - Set to **day after contract end**

- **Month Assignment**
  - Month is assigned based on the **adjusted Start Date**

---

# **Backdated ARR**

### **Dates**
- **Start Date**
  - Always use **original contract start date**

- **ARR Activation Date**
  - Closed Won → **invoice date**  
  - Closed Lost → **close date**

- **Renewal Start Date**
  - Closed Won → use **renewal invoice date** if later  
  - Closed Lost → use **renewal close date** if later  

- **Parent → Renewal (Overlap Prevention)**
  - If renewal starts before previous contract ends → shift to  
    **day after the latest parent contract ends**  
  - Ensures there is **no overlap between parent and renewal ARR periods**

- **Missing Renewal Start**
  - Set to **day after contract end**

- **Month Assignment**
  - Month is assigned based on the **adjusted Start Date**

---

# **Records Produced in Output**

### **1. Base Contract Rows (business categories)**
Each row represents a contract line classified into one of:
- **New Business** → first-time sale  
- **Renewal** → continuation of an existing contract  
- **Upsell / Expansion** → increase in scope or value within existing customer  

These rows:
- use adjusted dates (based on ARR type rules above)  
- carry the full contract amount  
- represent the **actual business transaction**

---

### **2. Price Increase / Downsell Rows (derived)**
Created when:
- deal is **Closed Won**
- and has a **previous contract (parent)**  

- Category becomes:
  - **Price Increase or Downsell**

These rows:
- do **not represent a standalone deal**
- store the contract amount to later calculate:
  - increase (higher than parent)
  - downsell (lower than parent)

---

### **3. Cancellation Rows (derived)**
Created when:
- deal is **Closed Lost**
- has a **previous contract**
- previous contract had **non-zero value**

- Category becomes:
  - **Cancellation**

These rows:
- represent **loss of ARR** from the previous contract  
- ensure ARR is removed when a renewal does not happen  

---

# **One-line summary**
- Dates are aligned to real events (invoice / close), adjusted for continuity and overlap prevention, and extended when needed  
- Output contains:
  - **actual contract rows (New, Renewal, Upsell)**
  - plus **derived rows for price changes and cancellations**



# **Technical Documentation**

## Purpose

`int_arr_base` applies ARR-type-specific timing logic, aligns parent/renewal continuity, assigns records to reporting months, and produces three types of output rows:
- base contract rows
- placeholder rows for future price increase/downsell calculation
- cancellation rows for failed renewals
---

## Summary Mapping



| Requirement | Model Section | Unit Tests |
|------------|-------------|------|
| Realized start dates | ARR_Data_base | int_arr_base_true_shifts_start_date_to_invoiced_date_when_later<br>int_arr_base_true_closed_lost_shifts_start_date_to_close_date<br>int_arr_base_true_uses_renewal_close_date_for_closed_lost_renewal |
| Backdated activation | ARR_Data | int_arr_base_backdated_keeps_sfdc_start_date_and_sets_activation_date<br>int_arr_base_backdated_closed_lost_sets_activation_date_to_close_date<br>int_arr_base_backdated_non_won_non_lost_keeps_default_activation_date |
| Parent overlap prevention | ARR_Data | int_arr_base_shifts_start_date_forward_when_gap_with_parent_exists<br>int_arr_base_keeps_start_date_when_no_gap_adjustment_needed |
| Default renewal start | ARR_Data | int_arr_base_defaults_renewal_start_date_to_day_after_end_date_when_missing |
| Preliminary end-date logic | ARR_Data | int_arr_base_preliminary_uses_tx_grace_period_when_earlier_than_renewal_cutoff<br>int_arr_base_preliminary_biz_dev_uses_6_month_end_date_grace_period<br>int_arr_base_preliminary_other_state_uses_60_day_end_date_grace_period<br>int_arr_base_preliminary_closed_lost_renewal_uses_renewal_close_date_minus_1_for_end_date |
| Preliminary parent end-date | ARR_Data | int_arr_base_preliminary_biz_dev_uses_6_month_max_parent_end_date_grace_period<br>int_arr_base_preliminary_other_state_uses_60_day_max_parent_end_date_grace_period<br>int_arr_base_preliminary_tx_uses_90_day_max_parent_end_date_grace_period<br>int_arr_base_preliminary_closed_lost_uses_close_date_minus_1_for_max_parent_end_date |
| Month assignment | ARR_Data_extended | int_arr_base_true_shifts_start_date_to_invoiced_date_when_later<br>int_arr_base_shifts_start_date_forward_when_gap_with_parent_exists |
| Base rows | New_Renewal_data | int_arr_base_creates_placeholder_row_for_parented_non_lost_opportunity<br>int_arr_base_shifts_start_date_forward_when_gap_with_parent_exists<br>int_arr_base_preliminary_biz_dev_uses_6_month_max_parent_end_date_grace_period |
| Placeholder rows | placeholder_data | int_arr_base_creates_placeholder_row_for_parented_non_lost_opportunity<br>int_arr_base_creates_placeholder_row_with_biz_dev_bucket |
| Cancellation rows | Cancellation_data | int_arr_base_creates_cancellation_row_for_parented_closed_lost_opportunity<br>int_arr_base_creates_cancellation_row_with_arr_bucket |
{% enddocs %}