CREATE DATABASE IF NOT EXISTS kolkata_healthcare_dw;
USE kolkata_healthcare_dw;

DROP TABLE IF EXISTS bronze_patients;
CREATE TABLE bronze_patients (
    patient_id VARCHAR(20), patient_name VARCHAR(200), gender VARCHAR(20), dob VARCHAR(30),
    city VARCHAR(100), state VARCHAR(100), locality VARCHAR(150), mobile VARCHAR(30),
    email VARCHAR(200), registration_date VARCHAR(30)
);

DROP TABLE IF EXISTS bronze_doctors;
CREATE TABLE bronze_doctors (
    doctor_id VARCHAR(20), doctor_name VARCHAR(200), specialization VARCHAR(100),
    experience_years VARCHAR(20), hospital_ids VARCHAR(500)
);

DROP TABLE IF EXISTS bronze_hospitals;
CREATE TABLE bronze_hospitals (
    hospital_id VARCHAR(20), hospital_name VARCHAR(250), location VARCHAR(150), city VARCHAR(100),
    state VARCHAR(100), bed_capacity VARCHAR(30), hospital_type VARCHAR(50), major_specialities VARCHAR(1000)
);

DROP TABLE IF EXISTS bronze_admissions_json;
CREATE TABLE bronze_admissions_json (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admission_id VARCHAR(50),
    raw_json JSON
);
