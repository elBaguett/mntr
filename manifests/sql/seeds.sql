INSERT INTO patient (
  patient_id, first_name, last_name, updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)), 'Иван', 'Иванов', to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);

INSERT INTO staff (
  staff_id, first_name, last_name, updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)), 'Анна', 'Сидорова', to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);

INSERT INTO medical_card (
  medcard_id, patient_id, anamnesis, updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)),
  (SELECT patient_id FROM patient LIMIT 1), 
  'Нет хронических заболеваний',
  to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);


INSERT INTO appointment (
  appointment_id, patient_id, anamnesis, updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)),
  (SELECT patient_id FROM patient LIMIT 1),
  'Первичный осмотр',
  to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);

INSERT INTO report (
  report_id, staff_id, updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)),
  (SELECT staff_id FROM staff LIMIT 1),
  to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);

INSERT INTO visit_log (
  visit_id,
  patient_id,
  staff_id,
  medical_card_id,
  report_id,
  appointment_id,
  updated_at
) VALUES (
  (SELECT MD5(clock_timestamp()::text)),
  (SELECT patient_id FROM patient LIMIT 1),
  (SELECT staff_id FROM staff LIMIT 1),
  (SELECT medcard_id FROM medical_card LIMIT 1),
  (SELECT report_id FROM report LIMIT 1),
  (SELECT appointment_id FROM appointment LIMIT 1),
  to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SS.MS')
);