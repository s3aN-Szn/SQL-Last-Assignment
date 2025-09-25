-- clinic_schema.sql
-- CREATE DATABASE and schema for a Clinic Booking System
-- Author: ChatGPT (example)
-- Run: mysql -u root -p < clinic_schema.sql

DROP DATABASE IF EXISTS clinic_db;
CREATE DATABASE clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE clinic_db;

-- Table: specialties (lookup)
CREATE TABLE specialties (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Table: doctors
CREATE TABLE doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    specialty_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_doctor_specialty FOREIGN KEY (specialty_id) REFERENCES specialties(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Table: patients
CREATE TABLE patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(50),
    date_of_birth DATE,
    gender ENUM('male','female','other') DEFAULT 'other',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: appointments (one-to-many: patient -> appointment; doctor -> appointment)
CREATE TABLE appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    scheduled_at DATETIME NOT NULL,
    duration_minutes INT DEFAULT 30,
    status ENUM('scheduled','completed','cancelled','no-show') DEFAULT 'scheduled',
    reason VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_appointment_patient FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_appointment_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uq_doctor_time UNIQUE (doctor_id, scheduled_at) -- simple constraint to avoid exact double-book of same datetime
) ENGINE=InnoDB;

-- Table: medications
CREATE TABLE medications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    UNIQUE (name)
) ENGINE=InnoDB;

-- Table: prescriptions (many-to-one to appointment, many-to-many to medications via prescription_items)
CREATE TABLE prescriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    notes TEXT,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_prescription_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Many-to-many join: prescription_items (prescription <-> medication)
CREATE TABLE prescription_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medication_id INT NOT NULL,
    dose VARCHAR(100),
    frequency VARCHAR(100),
    duration VARCHAR(100),
    CONSTRAINT fk_prescriptionitem_prescription FOREIGN KEY (prescription_id) REFERENCES prescriptions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_prescriptionitem_medication FOREIGN KEY (medication_id) REFERENCES medications(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_prescription_medication UNIQUE (prescription_id, medication_id)
) ENGINE=InnoDB;

-- Table: notes (optionally attach notes to appointments)
CREATE TABLE appointment_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    author VARCHAR(200), -- could be doctor name
    note TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_note_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Indexes (for common queries)
CREATE INDEX idx_patients_lastname ON patients(last_name);
CREATE INDEX idx_doctors_lastname ON doctors(last_name);
CREATE INDEX idx_appointments_scheduled_at ON appointments(scheduled_at);

-- Sample data (optional)
INSERT INTO specialties (name) VALUES ('General Practice'), ('Pediatrics'), ('Dermatology'), ('Cardiology');

INSERT INTO doctors (first_name,last_name,email,phone,specialty_id)
VALUES ('Alice','Brown','alice.brown@example.com','+254700111222', 1),
       ('John','Doe','john.doe@example.com','+254700333444', 2);

INSERT INTO patients (first_name,last_name,email,phone,date_of_birth,gender)
VALUES ('Mary','Njoroge','mary.njoroge@example.com','+254700555666','1988-05-12','female'),
       ('James','Kimani','james.kimani@example.com','+254700777888','1975-11-02','male');

INSERT INTO appointments (patient_id, doctor_id, scheduled_at, duration_minutes, status, reason)
VALUES (1,1,'2025-10-01 09:00:00',30,'scheduled','Routine checkup'),
       (2,2,'2025-10-02 10:30:00',45,'scheduled','Child fever');

-- Done
