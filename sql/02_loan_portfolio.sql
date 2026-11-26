# Outstanding Principal per Loan
# DE: Berechnet die verbleibende Restschuld je Darlehen, indem die erfassten Tilgungen vom ursprünglichen Darlehensbetrag abgezogen werden.
# EN: Calculates the remaining principal balance per loan by subtracting recorded principal repayments from the original loan amount.
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

# DE: Zeigt die berechnete Restschuld für jedes Darlehen an.
# EN: Displays the calculated outstanding principal for each loan.
Select * From vw_loan_balance Order By loan_id;

# Outstanding Principal by Product and Status
# DE: Aggregiert die Restschuld nach Kreditprodukt und Darlehensstatus, um die Verteilung des Kreditportfolios zu analysieren.
# EN: Aggregates outstanding principal by loan product and status to analyze the loan portfolio distribution.
Select lp.name As loan_product, b.loan_status,
       Count(*) As loan_count,
       Sum(b.outstanding_principal) As total_outstanding_principal
From vw_loan_balance b
Join loan_products lp On lp.id = b.loan_product_id
Group By lp.id, lp.name, b.loan_status
Order By total_outstanding_principal DESC;


