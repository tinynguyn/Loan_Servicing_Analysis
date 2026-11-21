#Create a view to display the balance of each loan
Create view vw_loan_balance As
With Paid As (
    Select p.loan_id, Sum(pa.principal_paid) As principal_paid
    From payments p
    Join payment_allocations pa On pa.payment_id = p.id
    Group By p.loan_id
)
Select al.id As loan_id, al.customer_id, al.loan_product_id,
       al.status As loan_status, al.principal_amount,
       Coalesce(pd.principal_paid, 0) As principal_paid,
       al.principal_amount - Coalesce(pd.principal_paid, 0) As outstanding_principal
From active_loans al
Left Join Paid pd On pd.loan_id = al.id;

Select * From vw_loan_balance Order By loan_id;

# 
Select lp.name As loan_product, b.loan_status,
       COUNT(*) As loan_count,
       SUM(b.outstanding_principal) As total_outstanding_principal
From vw_loan_balance b
Join loan_products lp On lp.id = b.loan_product_id
Group By lp.id, lp.name, b.loan_status
Order By total_outstanding_principal DESC;

# 
Select c.id As customer_id, CONCAT(c.first_name, ' ', c.last_name) As customer_name,
       COUNT(*) As loan_count,
       SUM(b.outstanding_principal) As total_outstanding_principal
From vw_loan_balance b
Join customers c On c.id = b.customer_id
Group By c.id, c.first_name, c.last_name
Order By total_outstanding_principal DESC
Limit 10;


