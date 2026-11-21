
Select 
    Date_Format(p.payment_date, '%Y-%m') As payment_month,
    SUM(pa.principal_paid) As principal_collected,
    SUM(pa.interest_paid) As interest_collected,
    SUM(pa.fees_paid) As fees_collected,
    SUM(pa.penalty_paid) As penalties_collected,
    SUM(pa.principal_paid + pa.interest_paid + pa.fees_paid + pa.penalty_paid) As total_allocated
From payments p
Join payment_allocations pa On pa.payment_id = p.id
Group By Date_Format(p.payment_date, '%Y-%m');

Select 
    schedule_id, 
    loan_id, 
    installment_number, 
    due_date,
    total_due, 
    allocated_due, 
    unpaid_amount
From vw_schedule_balance
Where due_date < CURDATE() And unpaid_amount > 0
Order By due_date, unpaid_amount DESC;

