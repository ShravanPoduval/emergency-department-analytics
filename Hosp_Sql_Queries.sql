show databases;
create database hospital_ed;
use hospital_ed;
show tables;
select * from ed_visits;

# Total ED Visits
SELECT COUNT(*) AS total_ed_visits
FROM ed_visits;

# Visits by Department
SELECT department, COUNT(*) AS total_visits
FROM ed_visits
GROUP BY department
ORDER BY total_visits DESC;

# Avg Wait Time by Department
SELECT department, ROUND(AVG(wait_time_minutes), 2) AS avg_wait
FROM ed_visits
WHERE wait_time_minutes IS NOT NULL
GROUP BY department
ORDER BY avg_wait DESC;

# Avg Length of Stay (LOS) by Department
SELECT department, ROUND(AVG(length_of_stay_minutes), 2) AS avg_los
FROM ed_visits
WHERE length_of_stay_minutes IS NOT NULL
GROUP BY department
ORDER BY avg_los DESC;

# Triage Level Analysis
SELECT triage_level, COUNT(*) AS total_patients, ROUND(AVG(wait_time_minutes), 2) AS avg_wait, ROUND(AVG(length_of_stay_minutes), 2) AS avg_los
FROM ed_visits
GROUP BY triage_level
ORDER BY triage_level;

# Hourly Arrival Pattern (peak hours)
SELECT arrival_hour, COUNT(*) AS total_arrivals
FROM ed_visits
GROUP BY arrival_hour
ORDER BY total_arrivals DESC;

# Weekend vs Weekday
SELECT is_weekend, COUNT(*) AS total_visits
FROM ed_visits
GROUP BY is_weekend;

# Top Chief Complaints
SELECT chief_complaint, COUNT(*) AS total_cases
FROM ed_visits
GROUP BY chief_complaint
ORDER BY total_cases DESC
LIMIT 10;

# Doctor Workload
SELECT doctor_id, COUNT(*) AS patients_seen
FROM ed_visits
WHERE doctor_id != -1
GROUP BY doctor_id
ORDER BY patients_seen DESC;

# Bed Usage
SELECT bed_id, COUNT(*) AS usage_count
FROM ed_visits
WHERE bed_id != -1
GROUP BY bed_id
ORDER BY usage_count DESC;

# ED Boarding (patients with long LOS > 360 minutes = 6 hours)
SELECT COUNT(*) AS long_boarding_cases
FROM ed_visits
WHERE length_of_stay_minutes > 360;

# Identify High-Wait-Time Days
SELECT arrival_date, ROUND(AVG(wait_time_minutes),2) AS avg_wait
FROM ed_visits
GROUP BY arrival_date
ORDER BY avg_wait DESC
LIMIT 10;

# Patients with invalid timestamps
SELECT *
FROM ed_visits
WHERE flag_invalid_treatment_time = 1
   OR flag_invalid_discharge_time = 1;

# Day vs Night Shift Comparison
SELECT
    CASE 
        WHEN arrival_hour BETWEEN 7 AND 18 THEN 'Day Shift'
        ELSE 'Night Shift'
    END AS shift_type,
    COUNT(*) AS total_patients,
    ROUND(AVG(wait_time_minutes),1) AS avg_wait
FROM ed_visits
GROUP BY shift_type;

# Patients Waiting Over 90 Minutes (Severe Overcrowding)
SELECT COUNT(*) AS long_waiting_patients
FROM ed_visits
WHERE wait_time_minutes > 90;

# Daily Time Series (Needed for forecasting)
SELECT 
    arrival_date,
    COUNT(*) AS daily_arrivals,
    ROUND(AVG(wait_time_minutes),1) AS avg_wait
FROM ed_visits
GROUP BY arrival_date
ORDER BY arrival_date;

# Chief Complaint Severity Analysis
SELECT 
    chief_complaint,
    COUNT(*) AS total_cases,
    ROUND(AVG(wait_time_minutes),1) AS avg_wait
FROM ed_visits
GROUP BY chief_complaint
ORDER BY avg_wait DESC;

# Peak Hour Overcrowding Tag
SELECT arrival_hour, COUNT(*) AS total
FROM ed_visits
GROUP BY arrival_hour
ORDER BY total DESC;

WITH hourly AS (
    SELECT arrival_hour, COUNT(*) AS total
    FROM ed_visits
    GROUP BY arrival_hour
)
SELECT 
    arrival_hour,
    total,
    CASE 
        WHEN total >= (SELECT AVG(total) * 1.5 FROM hourly) THEN 'Overcrowded'
        WHEN total >= (SELECT AVG(total) FROM hourly) THEN 'Busy'
        ELSE 'Normal'
    END AS crowd_level
FROM hourly
ORDER BY total DESC;



CREATE OR REPLACE VIEW ed_summary AS
SELECT
    patient_id,
    arrival_date,
    arrival_hour,
    arrival_day_of_week,
    is_weekend,
    department,
    chief_complaint,
    triage_level,
    wait_time_minutes,
    length_of_stay_minutes,
    doctor_id,
    bed_id
FROM ed_visits;






