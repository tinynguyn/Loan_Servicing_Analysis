# Overdue Loan Monitoring
# DE: Zeigt offene und noch nicht erledigte Zahlungsrückstände sowie die erfassten Verzugstage zur Überwachung des Kreditrisikos.
# EN: Displays unresolved delinquency records and recorded days past due to support credit risk monitoring.
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
