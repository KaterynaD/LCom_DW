{% docs table_fact_customer %}

Table aggregates monthly customer lifecycle states per Ultimate Parent Account (Customer), based on non-0 ARR in fact_arr table.
 

A customer is ultimate parent account based on ultimate\_parent\_id\_\_c attribute of Account object (dim_account). Non-0 ARR contracts (opportunities) may exist at the level of the ultimate parent account or its child accounts.

A customer may have an opportunity with revenue, not categorized as ARR (NRR) only. It is NOT counted as a customer from this contract.

 
**Net Active** = Active Customers at the Start of Fiscal Year + New + Returning – Churn - Expired

**Total Active** = Active Customers at the Start of Fiscal Year + New + Returning

*Active Customers at the Start of Fiscal Year* are reset each Fiscal Year, e.g. active on June 30, last day of a previous Fiscal Year



**Contract Active** = Customers from active, not expired non-0 ARR contracts (invoiced, Won opportunities) in the current month without any relations to ARR dataset.





**New** = first contract ever for the parent account  in the month

**Returning** = contracts resume in the month (had an active contract in a past, but not in a previous month)


**Churn** = contract canceled (Closed Lost) during the month and no other active contracts exist for the customer or its child accounts in the month. Churned customers have formally Closed Lost contracts or no active contracts in a month because of expiration or other events like moving into zero dollar ARR (non-paying) customers category.



**Non-paying Customers**: There are recurring contracts with $0 ARR amounts. Customers from these opportunities receive the service as Pilot Users or State Initiative Users (“State” pays for their usage). **They are not counted in this data set.**

State or District deal and Product Segmentation are not included in the current data set due to controversial situations for New, Returning and Churn customers.

A customer may have State (BizDev) and district ARR lines in the same time and one  or more opportunities or underlying accounts.

SFDC Product and State or District flag can be easily added to Net Active, Total Active, Contract Active. However there is a significant difficulties for Charn, New and Returning customers.An existing customer can add a new product replacing the same by functionality just an internal update, individual sku/product retire. Or it can be a new product from a different Sub Family. The process to identify new, and especcially returning, customers per product is complex. 

NonRenewed is one more potentioal customer record type, when a customer no longer use a specific SFDC product, but still a customer. It is not calculated right now due to the same complexity as as for Churn, New and Returning.


Table materialization is used because it's based on fact_arr incremental model to preserve history and the table size is small. Only Contract Active history is not preserve. 

{% enddocs %}