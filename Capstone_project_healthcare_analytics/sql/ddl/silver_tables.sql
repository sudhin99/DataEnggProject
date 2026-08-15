USE kolkata_healthcare_dw;

DROP TABLE IF EXISTS silver_billing;
DROP TABLE IF EXISTS silver_treatment;
DROP TABLE IF EXISTS silver_admission;
DROP TABLE IF EXISTS silver_doctor_hospital;
DROP TABLE IF EXISTS silver_hospitals;
DROP TABLE IF EXISTS silver_doctors;
DROP TABLE IF EXISTS silver_patients;

CREATE TABLE silver_patients (
    patient_id VARCHAR(20) PRIMARY KEY, patient_name VARCHAR(200), gender VARCHAR(20), dob DATE,
    age INT, age_group VARCHAR(20), city VARCHAR(100), state VARCHAR(100), locality VARCHAR(150), registration_date DATE
);

CREATE TABLE silver_doctors (
    doctor_id VARCHAR(20) PRIMARY KEY, doctor_name VARCHAR(200), specialization VARCHAR(100), experience_years INT
);

CREATE TABLE silver_hospitals (
    hospital_id VARCHAR(20) PRIMARY KEY, hospital_name VARCHAR(250), location VARCHAR(150), city VARCHAR(100),
    state VARCHAR(100), bed_capacity INT, hospital_type VARCHAR(50), major_specialities VARCHAR(1000)
);

CREATE TABLE silver_doctor_hospital (
    doctor_id VARCHAR(20), hospital_id VARCHAR(20), PRIMARY KEY (doctor_id, hospital_id)
);

CREATE TABLE silver_admission (
    admission_id VARCHAR(50) PRIMARY KEY, patient_id VARCHAR(20), doctor_id VARCHAR(20), hospital_id VARCHAR(20),
    admission_date DATE, discharge_date DATE, diagnosis VARCHAR(250), room_type VARCHAR(50), admission_type VARCHAR(50), referral_source VARCHAR(100)
);

CREATE TABLE silver_treatment (
    treatment_id VARCHAR(80) PRIMARY KEY, admission_id VARCHAR(50), treatment_name VARCHAR(250), treatment_date DATE, treatment_cost DECIMAL(12,2)
);

CREATE TABLE silver_billing (
    bill_id VARCHAR(80) PRIMARY KEY, admission_id VARCHAR(50), total_bill DECIMAL(12,2), discount DECIMAL(12,2),
    patient_payable DECIMAL(12,2), payment_mode VARCHAR(50), payment_status VARCHAR(50)
);
