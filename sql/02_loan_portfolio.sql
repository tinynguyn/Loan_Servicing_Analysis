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

