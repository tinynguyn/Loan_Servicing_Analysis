#Welche Darlehen haben noch keine Auszahlung erhalten?
#Which loans have not received any disbursement yet?
Select 
	al.id,
    customer_id,
    principal_amount,
    start_date,
    status
From active_loans al 
Left Join disbursements di On al.id = di.loan_id
Where di.loan_id is Null
	And al.status = 'active';

#Welche Darlehen haben einen gesamten Auszahlungsbetrag, der den vertraglichen Darlehensbetrag überschreitet?
#Which loans have a total disbursed amount that exceeds the contractual loan amount?
Select 
	al.id as Loan_id,
    customer_id As Customer_id,
    principal_amount,
    Sum(di.amount) As Total_Disbursed,
    SUM(di.amount) -  al.principal_amount As Excess_Amount
From disbursements di
Join active_loans al On di.loan_id = al.id
Group by al.id 
Having Sum(di.amount) > al.principal_amount;

#Wie viele Darlehen weisen einen gesamten Auszahlungsbetrag auf, der den vertraglichen Darlehensbetrag überschreitet?
#How many loans have a total disbursed amount that exceeds the contractual loan amount?
With Excess As(
	Select 
		al.id as Loan_id,
		customer_id As Customer_id,
		principal_amount,
		Sum(di.amount) As Total_Disbursed,
		SUM(di.amount) -  al.principal_amount As Excess_Amount
	From disbursements di
	Join active_loans al On di.loan_id = al.id
	Group by al.id 
	Having Sum(di.amount) > al.principal_amount)
Select Count(*) As Total_Excess
From Excess;

