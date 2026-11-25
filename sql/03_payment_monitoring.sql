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
# Uses November 2024 as the reference month for analyzing historical data.

