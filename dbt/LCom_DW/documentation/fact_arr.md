{% docs table_fact_arr %}

# Overview

The ARR (Annual Recurring Revenue) table establishes a consistent and business-aligned framework for tracking, interpreting, and reporting recurring revenue based on Salesforce opportunities data, while addressing real-world data inconsistencies and operational complexities.

---

## Business Context

In Salesforce, contracts are represented as opportunities and associated product lines. However, due to operational realities, the data does not always follow ideal structures:

- Payments are often delayed or occur out of sequence relative to contract start and end dates  
- Renewal contracts may remain open (neither won nor lost) for extended periods  
- Renewal timing is inconsistent — contracts may overlap, start early, start late, or contain gaps  
- Some legacy contracts are missing key attributes such as start and end dates  
- Not all contracts have clearly defined renewal outcomes  
- A single renewal opportunity replaces multiple parent opportunities that may end on different dates.
- Contracts may contain mixed business models and pricing structures within the same opportunity  

### Contract Types

- **State (Biz Dev)**  
  Revenue-generating contracts that fund usage for other accounts  

- **State Initiative**  
  $0 contracts that grant product access but do not contribute to ARR  

- **District (ARR)**  
  Standard revenue-generating contracts with associated licenses  

### Classification Logic

ARR classification is based on opportunity product-level attributes:

- Business type: `New Business`, `Renewal`, `Upsell`  
- Business model: `ARR` or `Biz Dev`  

> Note: A single contract may contain a mix of ARR and Biz Dev lines, including $0 and non-zero amounts.

---

## Key Challenges Addressed

The ARR model is designed to handle:

- Misaligned contract and renewal dates  
- Gaps or overlaps between contract periods  
- Missing or incomplete contract data  
- Mixed revenue types within a single contract  
- Product changes across renewals within the same product family  
- Account hierarchy inconsistencies between related contracts  

---

## Standardized Business Rules

### Contract Timing Logic

- ARR is anchored to the **contract start date**
- If a renewal starts before the parent contract ends → shift to **next day after parent ends**
- If a renewal starts after a gap → preserve gap and start ARR based on renewal start date
- Contracts without renewals → **expire naturally**


---

## ARR Calculation Methodologies

### 1. True ARR (Actuals)

- ARR is recognized only when:
  - Payment is received (**invoiced date**) for won contracts  
  - OR cancellation is confirmed (**close date of lost contracts**)  
- ARR decreases when contracts expire without renewal  

**Purpose:** Represents *actual realized revenue*

---

### 2. Backdated ARR (Adjusted Historical View)

- ARR is tied to the **contract start date**, but recognized only when:
  - Payment is received  
  - OR cancellation is confirmed  
- Historical periods are **retroactively adjusted** when new information becomes available  

**Purpose:** Represents *financially accurate historical reporting*

---

### 3. Preliminary ARR (Expected Revenue View)

- Applies a **grace period** for expected payments:
  - 6 months → State (Biz Dev) deals  
  - 90 days → Texas accounts  
  - 60 days → All other District accounts  

- ARR is temporarily recognized during the grace period even if payment is not yet received  
- Contracts expire only after the grace period if no payment or cancellation occurs  

**Purpose:** Represents *forward-looking, operational ARR*

---

## Additional Business Considerations

- Renewal contracts may reference different product IDs than their parent contracts, while still belonging to the same product family.  
- ARR price changes (increase/downsell/upsell) can occur at multiple levels:
  - Product  
  - Product sub-family  
  - Opportunity  
  - Account  

- In the current business process, Upsell vs Renewal (increase or downsell) is determined at the **opportunity level** and then manually allocated across opportunity product lines. As a result, the same product’s ARR can be split between Upsell and Renewal buckets within a single opportunity. This allocation is not fully reliable, therefore reporting below the **opportunity level** (e.g., product or sub-family) is not recommended at this time.

- Parent and renewal contracts may belong to different accounts within the same hierarchy and aggregation at ultimate parent account level makes more sense  
## Technical Implementation of ARR Types

All three ARR types are processed in a single pipeline, with `ARR_Type` controlling behavior:

stg_valid_opportunities → stg_arr_base → int_arr_base → int_arr_monthly_changes → int_fact_arr → fact_arr

---

### Where Business Logic Is Implemented

**stg_valid_opportunities**  
Filters to ARR-eligible contracts:
- Closed Won with invoice and valid dates  
- Closed Lost only if tied to a valid renewal  
→ Defines the valid ARR population

**stg_arr_base**  
Builds ARR at product + bucket level and incorporates parent opportunities:
- Aggregates current vs parent ARR  
- Computes `max_parent_end_date` across all parents  
→ Enables parent-child comparison and prevents overlap in renewals

---

### Core ARR Type Logic (int_arr_base)

All rows from stg_arr_base are duplicated into:
`ARR_Type = True | Preliminary | Backdated`

- Negative and Replacment opportunuties are ignored
- "wire transfer" product is ignored

**Start Date Logic**
- **True & Preliminary**
  - Step 1: shift `start_date` to operational timing (`invoiced_date` (Won) or `close_date` (Lost))
  - Step 2: shift to `max_parent_end_date + 1` to prevent overlap
- **Backdated**
  - Skip Step 1 → keep contractual `start_date`
  - Apply Step 2 (to prevent overlap)
  - Store operational timing (`invoiced_date` (Won) or `close_date` (Lost)) separately in `arr_activation_date` / `arr_deactivation_date` → Defines when ARR becomes reportable

**End Date Logic**
- **Preliminary only**
  - Applies grace period:
    - 6 months for Biz Dev
    - 90 days for Texas
    - 60 days otherwise
- **True & Backdated**
  - No extension → This is the only difference between True and Preliminary

---

### Monthly Movement Logic (int_arr_monthly_changes)

Transforms ARR into monthly events:

- `ARR-Starting` → ARR active at fiscal year start  
- `ARR-MonthlyAdded` → new ARR, upsell, or renewal  
- `ARR-MonthlyReduced` → expiration or cancellation  

**Gap vs Continuity Rule**
- If `DATEDIFF(day, max_parent_end_date, start_date) > 1` → treated as new ARR (gap)
- Otherwise → treated as placeholder for price change in the downstream reporting, not new ARR)

**Backdated Behavior**
- Uses `arr_activation_date` / `arr_deactivation_date` to delay recognition until operationally confirmed
s

---

### Final ARR Output (int_fact_arr)

- Expands movement events across fiscal months  
- Produces running ARR (`record_type = 'ARR'`)  

→ Converts event-based logic into reporting-ready ARR balances

---

### ARR Type Summary

- **True**  
  ARR recognized when operationally realized (invoice/close)

- **Preliminary**  
  Same as True + forward-looking grace period

- **Backdated**  
  ARR aligned to contractual start date, but recognized only after activation

---

### ARR Amount Calculation (fact_arr)

At this stage, `arr_amount` is not a standalone ARR value per row, but a **signed component of ARR movement**.

The calculation assigns positive or negative contribution based on business meaning of each bucket:

- Positive (`+total_price`)
  - New Business, Renewal, Upsell, Starting  
- Negative (`-total_price`)
  - Expired ARR  
- Negative (`-parent_total_price`)
  - Cancellations (removal of prior ARR)  
- Net change (`total_price - parent_total_price`)
  - Price changes (increase / downsell)

→ This logic converts business events into **directional ARR movements** 

---

### Important Modeling Note

Each row represents a **partial ARR movement**, not a final ARR balance.

- The same opportunity/product may produce multiple rows  
- Different buckets represent different components of ARR change  
- Values are intentionally **not pre-aggregated**

As a result:

> `arr_amount` is only meaningful when **aggregated (SUM)** across the desired grain  
> (e.g., month, opportunity, account, or total ARR)

---

### Why Aggregation Is Required

The model follows an **event-based design**:

- `int_arr_monthly_changes` creates ARR movements  
- `int_fact_arr` spreads them across time  
- `fact_arr` assigns direction (+/-)

Final ARR is derived as:

- **Point-in-time ARR** → SUM of all active ARR rows  
- **Net ARR change** → SUM of movements within a period  

This ensures:
- Full transparency of ARR drivers  
- Correct handling of overlaps, renewals, and gaps  
- Flexibility in downstream reporting (Tableau, views)

---

### Practical Implication

- Use `SUM(arr_amount)` in all reporting layers  
- Do **not** interpret individual rows as ARR totals  
- Avoid reporting at overly granular levels unless aggregated

---
{% enddocs %}