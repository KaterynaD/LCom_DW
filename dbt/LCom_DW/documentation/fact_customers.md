{% docs table_fact_customers %}

Table aggregates monthly customer lifecycle states per Ultimate Parent Account, based on non-0 ARR in vw_fact_revenue_monthly_snapshots.

Account is a customer if it does have non-0 Active Renewal ARR. It means at least one, not closed and not invoiced renewal opportunity with non-0 ARR exists for the account or its child.

A customer is ultimate parent account based on ultimate\_parent\_id\_\_c attribute of Account object. Contracts (opportunities) may exist at the level of the ultimate parent account or its child accounts.

A customer may have an opportunity with revenue, not categorized as ARR (NRR only or no renewal opportunity and disable auto renewal) and that's why it's counted as a customer later than the first known contract.

**Net Active First month FY** = Starting or Existing at the start of the FY + New + Returning – Churn  
**Net Active** = Prev Month Net Active + New + Returning – Churn  
**Total Active** = End of prev month (Starting or Existing at the start of the current month) + New + Returning  
**Contract Active** = Customers from active, not expired contracts (opportunities) in the current month or have license\_unenforced set to True

Set operations are used to calculate Net Active in the data source.  
Applying +/- to Starting, New, Churn customers monthly counts do not result in the correct Net Active due to the specificity of the data and business.

**End of previous month (Starting or Existing at the start of the current month) customers count**

**ARR-Starting:** ARR from all active renewals as of June 30. These renewals are linked to parent contracts invoiced in the prior fiscal year. Renewals remain active if they are not yet in a Closed stage, or if they are in a Closed stage but have missing next-fiscal-year invoiced or close dates (Closed Lost). If ARR is 0 in an active renewal, aggregated ARR from parent contracts is used in case it's a temporary renewal stage issue.

Before Fiscal Year 2025/2026, historical data on active renewals is not available. Therefore, ARR-Starting is defined as the total ARR from all active (non-expired) contracts as of June 30, the end of the fiscal year. If a contract has both a current term and a renewal term active at the same time (e.g., the current term hasn’t expired yet, but the renewal has already been invoiced), only the most recent term is included in the ARR calculation to avoid double-counting. If a renewal contract is Close Lost, the current contract (even if License Uninforce is True) is NOT included in ARR-Starting.

Customers from ARR-Starting are the base to calculate current month Net Active and Total Active. It’s recalculated at the start of each FY instead of using previous FY ended Net Active to clean up any inconsistency in the data. It’s done because there are renewal opportunities added without a parent opportunity, or a renewal opportunity may have a different account than its parent opportunity.

**New and Returning**

It’s assumed a renewal opportunity is created for each Closed Won opportunity (Active Renewal ARR exists), and New/Returning customers are based on Closed Won Invoiced opportunities.  
Returning Customers are customers from any previous fiscal year but not in Starting or previous New categories in the current FY.

**Churn**

Definition: Churn is an ultimate parent account with 0 renewal ARR from all children.  
Churn is based on Closed Lost opportunity and sum of SFDC Account object ultimate\_parent\_current\_renewal\_arr\_\_c attribute for each child account.

**Churn and its impact on Net Active**

The above Churn definition can be applied only for Churn starting June 2025 when Renewal ARR is started calculating at the level of ultimate parent account and history of changes saved.

For previous months, we can apply only the current value which can be 0 if a customer did not return, but can be non-0 if a customer returned after churn.

Before FY 2025/2026 we may have Churned opportunities (Closed Lost Date in the current FY) where a parent opportunity expired before current FY Start and not included in Starting Customers.  
The account of such opportunities should not be extracted from Net Active Customers because it was not added in Net Active as Starting or New.

In practice, Churn is reported in the dashboard, not excluded from Net Active due to set operations used in the underlying data set and cannot be easily tested using only the final count of customers in the dashboard, e.g.  
Starting count + New count + Returning count – Churn count ≠ Net Active count

It can be a perfectly fine Churn opportunity, where a Customer was included in Starting or New/Renewal in the current FY. It should be and it is excluded from Net Active in the data source using set operations.  
But it’s possible to have another Close Won opportunity (new or renewal) which is invoiced in the same month as Closed Lost opportunity (Churn) for the same customer.

Net Active is calculated correctly in the data source using set operations — Customer excluded and then included.  
However, having only final customer numbers in the dashboard it is not possible to validate, e.g.  
Starting count + New count + Returning count – Churn count ≠ Net Active count

Theoretically, it should not be an issue for FY in and after 2025/2026 because Starting ARR is based on Active Renewals and only Active Renewals can be Closed Lost → Churn.  
Practically, there is no restriction to add a new opportunity in a “past” and then Close Lost it. Will see.

**Non-paying Customers**

There are recurring contracts with 0 ARR amounts. Customers from these opportunities receive the service as Pilot Users or State Initiative Users (“State” pays for their usage).

**Churn of Non-paying Customers**

0-ARR invalidates the definition of the customer and churn. If 0 ARR is an expected state of a customer, 0 Active Renewal ARR does not mean it’s churned.  
Churn what you see in Non-Paying customers data is based on Closed Lost date and misleading. A customer may have another Active Renewal with 0 ARR.

**Revenue Added → converting non-paying customer to a paying customer**

When a non-paying customer invoices a Closed Won opportunity, it’s removed from Non-Paying category to Paying Customers.  
The impact on Net Active Non-paying customers and related issues are the same as with Churn of paying Customers and described above.

**Net Active** = End of previous month (Starting or Existing at the start of the current month) + New + Returning – Churn – Revenue Added

Net Active in the data set is calculated via set operations and cannot be validated using  
Starting count + New count + Returning count – Churn count – Revenue Added count ≠ Net Active count  
formula based on the numbers you see in the dashboard. Because Churn and Revenue Added can be not included in Starting or were included in New/Returning in the same month.

{% enddocs %}