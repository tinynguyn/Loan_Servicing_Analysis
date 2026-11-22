# Overdue Loan Monitoring
# DE: Zeigt Darlehen mit erfassten Zahlungsrückständen und die Anzahl der Verzugstage zur Überwachung des Kreditrisikos.
# EN: Displays loans with recorded payment delinquencies and days past due to support credit risk monitoring.
Select
    al.id As loan_id,
    al.customer_id,
    al.status As loan_status,
    d.days_past_due,
    d.overdue_principal,
    d.overdue_interest,
    d.last_checked_date
From delinquencies d
Join active_loans al On d.loan_id = al.id
Where d.days_past_due > 0
Order By d.days_past_due DESC;

# Delinquency Distribution
# DE: Gruppiert Darlehen nach der maximal erfassten Anzahl an Verzugstagen, um die Verteilung der Zahlungsrückstände zu analysieren.
# EN: Groups loans by their maximum recorded days past due to analyze the distribution of payment delinquencies.
With LoanDPD As (
    Select
        loan_id,
        Max(days_past_due) As max_dpd
    From delinquencies
    Group By loan_id
)
Select
    Case
        When max_dpd Between 1 And 30 Then '1-30 days'
        When max_dpd Between 31 And 60 Then '31-60 days'
        When max_dpd Between 61 And 90 Then '61-90 days'
        Else '90+ days'
    End As dpd_category,
    Count(*) As loan_count
From LoanDPD
Where max_dpd > 0
Group By dpd_category
Order By Min(max_dpd);