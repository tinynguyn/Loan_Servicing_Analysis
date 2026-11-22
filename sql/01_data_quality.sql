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

#Excess Disbursement Count
# DE: Zählt die Darlehen, deren gesamte Auszahlungen den vertraglichen Darlehensbetrag überschreiten.
# EN: Counts loans where total disbursements exceed the contractual loan amount.
With Excess As(
	Select 
		al.id as Loan_id,
		customer_id As Customer_id,
		principal_amount,
		Sum(di.amount) As Total_Disbursed,
		Sum(di.amount) -  al.principal_amount As Excess_Amount
	From disbursements di
	Join active_loans al On di.loan_id = al.id
	Group by al.id 
	Having Sum(di.amount) > al.principal_amount)
Select Count(*) As Excess_disbursement_loans
From Excess;

