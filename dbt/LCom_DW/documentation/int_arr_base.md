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

The model processes data through:
- `ARR_Data_base`
- `ARR_Data`
- `ARR_Data_extended`
- output CTEs: `New_Renewal_data`, `placeholder_data`, `Cancellation_data`

---

## 1. Realized Start Dates (True & Preliminary ARR)

### Requirement
Start dates must reflect actual business events (invoice / close), not planned contract dates.

### Implementation
In `ARR_Data_base`:
- For non-Backdated ARR:
  - start_date = max(start_date, invoiced_date, close_date depending on status)
- renewal_start_date follows the same logic using renewal invoice/close dates

### Tests
- `int_arr_base_true_shifts_start_date_to_invoiced_date_when_later`
- `int_arr_base_true_closed_lost_shifts_start_date_to_close_date`
- `int_arr_base_true_uses_renewal_close_date_for_closed_lost_renewal`

---

## 2. Backdated ARR Activation Logic

### Requirement
Backdated ARR must keep original start date but track when ARR became active.

### Implementation
- start_date remains unchanged
- In `ARR_Data`:
  - arr_activation_date =
    - invoiced_date for Closed Won
    - close_date for Closed Lost
    - default otherwise

### Tests
- `int_arr_base_backdated_keeps_sfdc_start_date_and_sets_activation_date`
- `int_arr_base_backdated_closed_lost_sets_activation_date_to_close_date`
- `int_arr_base_backdated_non_won_non_lost_keeps_default_activation_date`

---

## 3. Parent → Renewal Continuity (No Overlap)

### Requirement
Renewal must not start before parent contract ends.

### Implementation
In `ARR_Data`:
- start_date = max(start_date, max_parent_end_date + 1 day)

### Tests
- `int_arr_base_shifts_start_date_forward_when_gap_with_parent_exists`
- `int_arr_base_keeps_start_date_when_no_gap_adjustment_needed`

---

## 4. Default Renewal Start Date

### Requirement
If renewal start is missing, assume continuity.

### Implementation
In `ARR_Data`:
- if renewal_start_date is missing → end_date + 1 day

### Tests
- `int_arr_base_defaults_renewal_start_date_to_day_after_end_date_when_missing`

---

## 5. Preliminary ARR End Date Grace Period

### Requirement
Preliminary ARR remains active after contract end until renewal outcome is known.

### Implementation
In `ARR_Data` (only for Preliminary):
- end_date = earlier of:
  - renewal cutoff:
    - renewal invoice date - 1 day (Closed Won)
    - renewal close date - 1 day (Closed Lost)
  - grace period:
    - +6 months for Business Development
    - +90 days for Texas
    - +60 days for others

### Tests
- `int_arr_base_preliminary_uses_tx_grace_period_when_earlier_than_renewal_cutoff`
- `int_arr_base_preliminary_biz_dev_uses_6_month_end_date_grace_period`
- `int_arr_base_preliminary_other_state_uses_60_day_end_date_grace_period`
- `int_arr_base_preliminary_closed_lost_renewal_uses_renewal_close_date_minus_1_for_end_date`

---

## 6. Preliminary Parent End Date Adjustment

### Requirement
Parent contract end date must follow same grace-period logic.

### Implementation
In `ARR_Data` (only for Preliminary):
- max_parent_end_date = earlier of:
  - current row event cutoff (invoice/close - 1 day)
  - grace period (same rules as above)

### Tests
- `int_arr_base_preliminary_biz_dev_uses_6_month_max_parent_end_date_grace_period`
- `int_arr_base_preliminary_other_state_uses_60_day_max_parent_end_date_grace_period`
- `int_arr_base_preliminary_tx_uses_90_day_max_parent_end_date_grace_period`
- `int_arr_base_preliminary_closed_lost_uses_close_date_minus_1_for_max_parent_end_date`

---

## 7. Month Assignment

### Requirement
Records must be assigned to reporting month based on effective start date.

### Implementation
In `ARR_Data_extended`:
- join to calendar where:
  - start_date between mon_firstday and mon_lastday

### Tests
Validated indirectly via `mon_year` in multiple tests where start_date shifts.

---

## 8. Base Contract Rows

### Requirement
All normalized contract rows must remain available.

### Implementation
`New_Renewal_data`:
- includes rows where:
  - stage_name != Closed Lost
  - total_price is not null

### Tests
Validated in:
- `int_arr_base_creates_placeholder_row_for_parented_non_lost_opportunity`
- `int_arr_base_shifts_start_date_forward_when_gap_with_parent_exists`
- `int_arr_base_preliminary_biz_dev_uses_6_month_max_parent_end_date_grace_period`

---

## 9. Price Increase / Downsell Placeholder Rows

### Requirement
Parented won renewals must produce rows for price change calculation.

### Implementation
`placeholder_data`:
- conditions:
  - hasparent = true
  - stage_name != Closed Lost
- creates new bucket: Placeholder for Price Increase or Downsell
- aggregates:
  - renewal amount
  - parent amount

### Tests
- `int_arr_base_creates_placeholder_row_for_parented_non_lost_opportunity`
- `int_arr_base_creates_placeholder_row_with_biz_dev_bucket`

---

## 10. Cancellation Rows

### Requirement
Failed renewals must remove parent ARR.

### Implementation
`Cancellation_data`:
- conditions:
  - hasparent = true
  - stage_name = Closed Lost
  - parent_total_price ≠ 0
- creates bucket: Cancellation
- carries parent_total_price only

### Tests
- `int_arr_base_creates_cancellation_row_for_parented_closed_lost_opportunity`
- `int_arr_base_creates_cancellation_row_with_arr_bucket`

---

## 11. Final Output Structure

### Requirement
All row types must be combined into a single dataset.

### Implementation
Final dataset = UNION ALL of:
- New_Renewal_data
- Placeholder_data
- Cancellation_data

Final select:
- enforces data types
- applies defaults
- aligns with schema contract

### Schema Constraints
Unique key:
- ARR_Type
- mon_year
- opportunity_id
- sfdc_product_id
- bucket

---

## Summary Mapping

| Requirement | Model Section | Tests |
|------------|-------------|------|
| Realized start dates | ARR_Data_base | 1, 13, 14 |
| Backdated activation | ARR_Data | 2, 15, 16 |
| Parent overlap prevention | ARR_Data | 7, 8 |
| Default renewal start | ARR_Data | 4 |
| Preliminary end-date logic | ARR_Data | 3, 9, 10, 17 |
| Preliminary parent end-date | ARR_Data | 11, 12, 18, 19 |
| Month assignment | ARR_Data_extended | multiple |
| Base rows | New_Renewal_data | multiple |
| Placeholder rows | placeholder_data | 5, 20 |
| Cancellation rows | Cancellation_data | 6, 21 |
{% enddocs %}