# Active Loans Without Disbursements
# DE: Identifiziert aktive Darlehen ohne erfasste Auszahlung, um mögliche Datenabweichungen zu erkennen.
# EN: Identifies active loans without recorded disbursements to detect potential data inconsistencies.
Select 
	al.id,
    customer_id,
    principal_amount,
    start_date,
    status
From active_loans al 
Left Join disbursements di On al.id = di.loan_id
Where di.loan_id is Null And al.status = 'active';

# Excess Disbursement Detection
# DE: Vergleicht die gesamten Auszahlungen je Darlehen mit dem vertraglichen Darlehensbetrag, um Überschreitungen zu erkennen.
# EN: Compares total disbursements with the contractual loan amount to identify potential excess disbursements.
Select 
	al.id as Loan_id,
    customer_id As Customer_id,
    principal_amount,
    Sum(di.amount) As Total_Disbursed,
    Sum(di.amount) -  al.principal_amount As Excess_Amount
From disbursements di
Join active_loans al On di.loan_id = al.id
Group by al.id 
Having Sum(di.amount) > al.principal_amount;

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

# Monthly Payment Collections
# DE: Berechnet die monatlich erfassten Tilgungs-, Zins-, Gebühren- und Strafzahlungsbeträge.
# EN: Calculates monthly recorded principal, interest, fee and penalty allocations to monitor payment collections.
Select 
    Date_Format(p.payment_date, '%Y-%m') As payment_month,
    Sum(pa.principal_paid) As principal_collected,
    Sum(pa.interest_paid) As interest_collected,
    Sum(pa.fees_paid) As fees_collected,
    Sum(pa.penalty_paid) As penalties_collected,
    Sum(pa.principal_paid + pa.interest_paid + pa.fees_paid + pa.penalty_paid) As total_allocated
From payments p
Join payment_allocations pa On pa.payment_id = p.id
Group By Date_Format(p.payment_date, '%Y-%m');

# Shared View: Installment Balance
# DE: Berechnet den offenen Betrag jeder Rate anhand des Tilgungsplans und der zugeordneten Zahlungen.
# EN: Calculates the unpaid amount of each installment by comparing scheduled dues with allocated payments.
Create view vw_schedule_balance As
With Allocated As (
    Select schedule_id,
           Sum(principal_paid + interest_paid + fees_paid) As allocated_due
    From payment_allocations
    Group By schedule_id
)
Select 
    s.id As schedule_id,
    s.loan_id, 
    s.installment_number, 
    s.due_date,
    s.total_due,
    Coalesce(a.allocated_due, 0) As allocated_due,
    s.total_due - Coalesce(a.allocated_due, 0) As unpaid_amount
From repayment_schedules s
Left Join Allocated a On a.schedule_id = s.id;

# Overdue and Unpaid Installments
# DE: Identifiziert überfällige Raten mit offenen Beträgen, um ausstehende Zahlungen zu überwachen.
# EN: Identifies overdue installments with unpaid amounts to monitor outstanding repayment obligations.
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

# Loans With Multiple Overdue Installments
# DE: Ermittelt Darlehen mit mehreren überfälligen Raten und summiert die offenen Beträge zur Unterstützung des Forderungsmanagements.
# EN: Identifies loans with multiple overdue installments and summarizes unpaid amounts to support debt collection monitoring.
Select
    loan_id, Count(*) As overdue_installments,
    Sum(unpaid_amount) As total_unpaid_amount
From vw_schedule_balance
Where due_date < CURDATE() And unpaid_amount > 0
Group By loan_id
HAVING COUNT(*) > 1
Order By 
        overdue_installments DESC, 
        total_unpaid_amount DESC;

# Previous Month's Loan Repayments
# DE: Berechnet die im vorherigen Kalendermonat erfassten Tilgungs- und Zinszahlungen für das monatliche Reporting.
# EN: Calculates recorded principal and interest payments from the previous calendar month for monthly reporting.
Select
    Date_Format(Curdate() - Interval 1 Month,'%Y-%m') As payment_month,
    Sum(pa.principal_paid) As principal_collected,
    Sum(pa.interest_paid) As interest_collected
From payments p
Join payment_allocations pa On p.id = pa.payment_id
Where p.payment_date >= Date_Format(Curdate() - Interval 1 Month, '%Y-%m-01')
And p.payment_date < Date_Format(Curdate(), '%Y-%m-01');

# Overdue Loan Monitoring
# DE: Zeigt offene und noch nicht erledigte Zahlungsrückstände sowie die erfassten Verzugstage 
# EN: Displays unresolved delinquency records and recorded days past due
Select
    al.id As loan_id,
    al.customer_id,
    al.status As loan_status,
    d.status As delinquency_status,
    d.days_past_due,
    d.overdue_principal,
    d.overdue_interest,
    d.overdue_principal + d.overdue_interest As recorded_overdue_amount,
    d.last_checked_date  
From delinquencies d
Join active_loans al On d.loan_id = al.id
Where d.days_past_due > 0 AND d.status IN ('open', 'in_collection', 'legal')
Order By d.days_past_due DESC;

