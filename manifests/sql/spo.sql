CREATE TABLE patient (
    patient_id VARCHAR(32) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    updated_at VARCHAR(24) NOT NULL
);

CREATE TABLE staff (
    staff_id VARCHAR(32) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name  VARCHAR(100) NOT NULL,
    updated_at VARCHAR(24) NOT NULL
);

CREATE TABLE medical_card (
    medcard_id VARCHAR(32) PRIMARY KEY,
    patient_id VARCHAR(32) NOT NULL,
    anamnesis TEXT,
    updated_at VARCHAR(24) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
);

CREATE TABLE appointment (
    appointment_id VARCHAR(32) PRIMARY KEY,
    patient_id     VARCHAR(32) NOT NULL,
    anamnesis      TEXT,
    updated_at     VARCHAR(24) NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
);

CREATE TABLE report (
    report_id VARCHAR(32) PRIMARY KEY,
    staff_id  VARCHAR(32) NOT NULL,
    updated_at VARCHAR(24) NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
);

CREATE TABLE visit_log (
    visit_id        VARCHAR(32) PRIMARY KEY,
    patient_id      VARCHAR(32) NOT NULL,
    staff_id        VARCHAR(32) NOT NULL,
    medical_card_id VARCHAR(32) NOT NULL,
    report_id       VARCHAR(32),
    appointment_id  VARCHAR(32),
    updated_at      VARCHAR(24) NOT NULL,
    FOREIGN KEY (patient_id)      REFERENCES patient (patient_id),
    FOREIGN KEY (staff_id)        REFERENCES staff (staff_id),
    FOREIGN KEY (medical_card_id) REFERENCES medical_card (medcard_id),
    FOREIGN KEY (report_id)       REFERENCES report (report_id),
    FOREIGN KEY (appointment_id)  REFERENCES appointment (appointment_id)
);