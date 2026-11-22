# Loan Servicing & Credit Risk Analysis | MySQL

## Project Overview

This project uses MySQL to analyze a simulated loan management database, focusing on loan portfolio analysis, payment monitoring and credit risk.

The goal is to demonstrate how SQL can support business analysis and decision making in loan servicing operations.

## Tools & Technologies

- **Database:** MySQL 8.0
- **Tools:** MySQL Workbench, VS Code
- **SQL Skills:** JOIN, CTE, GROUP BY, HAVING, CASE WHEN, Aggregate Functions, Views, Date Functions

## Dataset

The project uses the [Loan Management Sample Database](https://databasesample.com/datasets/loan-management-sample-database), containing 30 related tables with simulated banking and loan management data.

The analysis focuses on loan contracts, customers, disbursements, repayment schedules, payments, payment allocations, and delinquency records.

## Database Schema

![Database ERD](image/loan_erd.png)

## Analysis

### 1. Data Quality

`sql/01_data_quality.sql`

- Identify active loans without recorded disbursements.
- Detect loans with cumulative disbursements exceeding their contractual principal.
- Count loans flagged for potential disbursement inconsistencies.

### 2. Loan Portfolio Analysis

`sql/02_loan_portfolio.sql`

- Calculate outstanding principal for individual loans.
- Analyze outstanding principal by loan product and status.
- Identify the top 10 customers by total outstanding principal.

### 3. Payment Monitoring

`sql/03_payment_monitoring.sql`

- Analyze monthly principal, interest, fee, and penalty allocations.
- Identify overdue installments with unpaid amounts.
- Find loans with multiple overdue installments.
- Calculate principal and interest collections for the previous calendar month.

### 4. Credit Risk Analysis

`sql/04_credit_risk.sql`

- Identify loans with recorded payment delinquencies.
- Classify loans by their maximum recorded days past due (DPD).

## Key Findings

- Identified **868 loans** where cumulative recorded disbursements exceed the contractual principal amount.
- Developed reusable SQL views to calculate outstanding loan balances and unpaid installments.
- Created queries to support payment monitoring, portfolio analysis, and delinquency reporting.

## Limitations

The dataset contains synthetic data and some financial inconsistencies. Calculated outstanding balances and delinquency indicators should therefore be interpreted as analytical estimates rather than verified financial figures.

## Project Structure

```text
loan_prj/
├── README.md
├── data/
├── image/
│   └── loan_erd.png
└── sql/
    ├── 01_data_quality.sql
    ├── 02_loan_portfolio.sql
    ├── 03_payment_monitoring.sql
    └── 04_credit_risk.sql
```

