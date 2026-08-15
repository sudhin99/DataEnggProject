USE kolkata_healthcare_dw;

DROP TABLE IF EXISTS fact_billing;
DROP TABLE IF EXISTS fact_treatment;
DROP TABLE IF EXISTS fact_admission;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_hospital;
DROP TABLE IF EXISTS dim_doctor;
DROP TABLE IF EXISTS dim_patient;

CREATE TABLE dim_patient (
    patient_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    patient_id VARCHAR(20) UNIQUE, patient_name VARCHAR(200), gender VARCHAR(20), dob DATE,
    age INT, age_group VARCHAR(20), city VARCHAR(100), state VARCHAR(100), locality VARCHAR(150), registration_date DATE
);

CREATE TABLE dim_doctor (
    doctor_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    doctor_id VARCHAR(20) UNIQUE, doctor_name VARCHAR(200), specialization VARCHAR(100), experience_years INT
);

CREATE TABLE dim_hospital (
    hospital_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    hospital_id VARCHAR(20) UNIQUE, hospital_name VARCHAR(250), location VARCHAR(150), city VARCHAR(100),
    state VARCHAR(100), bed_capacity INT, hospital_type VARCHAR(50), major_specialities VARCHAR(1000)
);

CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE UNIQUE,
    month_number INT,
    month_name VARCHAR(20),
    quarter_number INT,
    year_number INT,
    season_name VARCHAR(30)
);

CREATE TABLE fact_admission (
    admission_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    admission_id VARCHAR(50) UNIQUE,
    patient_key BIGINT, doctor_key BIGINT, hospital_key BIGINT, admission_date_key INT,
    admission_date DATE, discharge_date DATE, diagnosis VARCHAR(250), room_type VARCHAR(50),
    admission_type VARCHAR(50), referral_source VARCHAR(100), admission_count INT DEFAULT 1
);

CREATE TABLE fact_treatment (
    treatment_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    treatment_id VARCHAR(80) UNIQUE,
    admission_key BIGINT,
    admission_id VARCHAR(50),
    treatment_name VARCHAR(250),
    treatment_date DATE,
    treatment_cost DECIMAL(12,2),
    treatment_count INT DEFAULT 1
);

CREATE TABLE fact_billing (
    billing_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    bill_id VARCHAR(80) UNIQUE,
    admission_key BIGINT,
    admission_id VARCHAR(50),
    total_bill DECIMAL(12,2),
    discount DECIMAL(12,2),
    patient_payable DECIMAL(12,2),
    payment_mode VARCHAR(50),
    payment_status VARCHAR(50)
);
