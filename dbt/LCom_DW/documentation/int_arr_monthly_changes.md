{% docs table_int_arr_monthly_changes %}
# **Business Logic Overview**

This model **stitches parent and renewal opportunities into a continuous ARR timeline**, ensuring:

- no overlap between contracts  
- correct handling of gaps  
- proper timing of ARR start and reduction  

At this stage, **there is no difference in how ARR Types (True, Preliminary, Backdated) are transformed**.  
All ARR Types follow the **same stitching, activation, and reduction logic**.

It transforms base contract rows into **monthly ARR movement records**:
- **ARR-Starting**
- **ARR-MonthlyAdded**
- **ARR-MonthlyReduced**

**ARR Activation Date and ARR Deactivation Date are meaningful for all ARR Types**, not only Backdated:

- due to the complexity of expiration logic, from this point forward they define the **effective active period of ARR records**  
- they ensure **expiration rows are correctly selected and applied**, especially in scenarios with gaps, no renewal, or renewal not yet ready for processing  

---

# **ARR Transformation Logic (All ARR Types)**

## **Starting**
- **Month**
  - first fiscal month  
- **Start Date**
  - same as adjusted Start Date from base  
- **End Date**
  - same as adjusted End Date from base  
- **Activation date**
  - same as defined in the base model  
- **Deactivation date**
  - open-ended (`3000-01-01`)  

**Condition:**
- **opportunity is active at the last day of the previous fiscal year**  
  (e.g. June 30 is between Start Date and End Date)

---

## **Monthly Added**
- **Month**
  - same as assigned in the base model (based on adjusted Start Date)  
- **Start Date**
  - same as adjusted Start Date from base  
- **End Date**
  - same as adjusted End Date from base  
- **Activation date**
  - same as in the base model  
- **Deactivation date**
  - open-ended (`3000-01-01`)  

---

## **Monthly Reduced / Expired**

Expiration is created when:

- there is a **gap before renewal starts**  
- there is **no renewal**  
- renewal exists but is **not ready for processing**

### **Month**
- based on the **expired opportunity End Date**

### **Start Date**
- expired opportunity **End Date**

### **End Date**
- depends on renewal:
  - Gap → open-ended  
  - No renewal → open-ended  
  - Not ready → open-ended  
  - Closed Won → day before renewal invoice date  
  - Closed Lost → day before renewal close date  

### **Activation date**
- same as **Start Date**

### **Deactivation date**
- same as **End Date**

---

# **Records Produced in Output**

## **ARR-Starting**
- ARR carried into the fiscal year opening month  

---

## **ARR-MonthlyAdded**
- ARR entering reporting in its assigned month  
- Includes:
  - New Business  
  - Renewal  
  - Upsell  

### **Placeholder (Price Increase / Downsell)**
- Created when:
  - opportunity **has a parent**
  - and is **not Closed Lost**  
- Uses:
  - same **Month, Start Date, End Date, Activation, Deactivation** as the renewal (from base)  
- Purpose:
  - derives:
    - **Price Increase (renewal > parent)**  
    - **Downsell (renewal < parent)**  
- Does **not represent standalone ARR**, only supports net change calculation  

---

## **ARR-MonthlyReduced**
- ARR removed from reporting because of:
  - Expired  
  - Cancelled  
  - Downsell  

---

# **One-line Summary**

This model builds a **continuous, non-overlapping ARR movement timeline** by carrying forward opportunities active at the last day of the previous fiscal year, adding ARR in its assigned month, using placeholder records to calculate price changes, and reducing ARR when contract end and renewal timing confirm a gap, no renewal, or a renewal not yet ready for processing.


# **Technical Documentation**

## Purpose
      Intermediate model for monthly ARR changes for all ARR Types logic.
      Produces monthly ARR starting, monthly additions, and reductions at the grain of
      ARR type, month, opportunity, product, and sfdc bucket, stitching together parent and renewals opportunities.

# Summary Mapping

| Model Section | Explanation | Business Requirement | Unit Tests |
|--------------|------------|---------------------|-------|
| starting_data | Creates ARR-Starting rows for opportunities active at fiscal start | Carry forward ARR into first fiscal month only if contract is still active | int_arr_monthly_changes_creates_starting_record_for_active_invoiced_won_opportunity; int_arr_monthly_changes_does_not_create_starting_record_when_contract_ends_day_before_fiscal_month_1 |
| add_monthly_new | Creates Monthly Added ARR for new business without parent | New ARR should be recognized when opportunity is won, invoiced, and has no parent | int_arr_monthly_changes_creates_monthly_added_for_won_invoiced_opportunity_without_parent |
| add_monthly_upsell | Creates Monthly Added ARR for upsell opportunities | Upsells must always be treated as ARR additions regardless of parent relationship | int_arr_monthly_changes_creates_monthly_added_for_upsell_even_with_parent |
| add_monthly_like_new | Treats parented renewals with gap as new ARR | If gap > 1 day between parent end and renewal start, treat as new ARR (restart logic) | int_arr_monthly_changes_creates_monthly_added_like_new_when_gap_after_parent_exceeds_one_day; int_arr_monthly_changes_does_not_create_like_new_monthly_added_when_no_gap_exists |
| add_monthly_placeholder_for_PI_or_downsell | Creates placeholder rows for price increase or downsell | If no gap between parent and renewal, treat as continuation and create placeholder for later PI/Downsell calculation | int_arr_monthly_changes_creates_placeholder_monthly_added_when_no_gap_after_parent; int_arr_monthly_changes_does_not_create_placeholder_monthly_added_when_gap_exceeds_one_day |
| add_monthly | Combines all ARR addition paths into one dataset | All ARR entering the system must be unified before applying reduction logic | Covered indirectly by tests of all upstream add_monthly_* CTEs |
| expired_monthly_added | Creates expiration rows for Monthly Added ARR | ARR must be reduced when contract ends and there is a gap, no renewal, or renewal not ready | int_arr_monthly_changes_creates_expiration_for_monthly_added_when_renewal_has_gap; int_arr_monthly_changes_creates_expiration_for_monthly_added_when_renewal_is_not_ready; int_arr_monthly_changes_monthly_added_closed_won_continuous_renewal_does_not_create_expiration; int_arr_monthly_changes_monthly_added_closed_lost_continuous_renewal_does_not_create_expiration |
| expired_starting_data | Creates expiration rows for Starting ARR across fiscal boundaries | Starting ARR must expire correctly even across fiscal-year boundaries and renewal timing scenarios | int_arr_monthly_changes_creates_expiration_for_starting_when_renewal_has_gap; int_arr_monthly_changes_creates_expiration_for_starting_when_renewal_is_not_ready; int_arr_monthly_changes_starting_expiration_deactivates_day_before_closed_won_renewal_invoice; int_arr_monthly_changes_starting_expiration_deactivates_day_before_closed_lost_renewal_close; int_arr_monthly_changes_creates_starting_expiration_in_first_fiscal_month_when_contract_ends_on_june_30 |
| cancellation_monthly | Creates cancellation rows for Closed Lost renewals without gap | Closed Lost renewal with no gap must be treated as cancellation instead of expiration | int_arr_monthly_changes_creates_cancellation_reduced_record_for_closed_lost_renewal_with_no_gap; int_arr_monthly_changes_does_not_create_cancellation_reduced_record_when_gap_exists |
| all_data | Unions all generated ARR movement rows | A single opportunity can produce multiple movement records (Starting, Added, Expired, Cancellation) | Covered indirectly by tests that validate multiple outputs per input |
| Final select | Normalizes output schema and bucket naming | Output must conform to reporting schema and standardized bucket labels |  |

{% enddocs %}