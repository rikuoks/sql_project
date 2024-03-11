CREATE TABLE job_applied (
    job_id INT,
    application_sent_date DATE,
    custom_resume BOOLEAN,
    resume_file_name VARCHAR(255),
    cover_letter_sent BOOLEAN,
    cover_letter_file_name VARCHAR(255),
    status VARCHAR(50)
)
;

SELECT * FROM job_applied
;

INSERT INTO job_applied
    (    
        job_id,
        application_sent_date,
        custom_resume,
        resume_file_name,
        cover_letter_sent,
        cover_letter_file_name,
        status
    )
VALUES
    (
        1,
        '2024-02-01',
        true,
        'resume_01.pdf',
        true,
        'cover_letter_01.pdf',
        'submitted'
    ),
    (
        2,
        '2024-02-02',
        true,
        'resume_02.pdf',
        true,
        'cover_letter_02.pdf',
        'submitted'
    ),
    (
        3,
        '2024-02-02',
        true,
        'resume_02.pdf',
        false,
        NULL,
        'submitted'
    )
;

UPDATE job_applied SET resume_file_name = 'resume_03.pdf' WHERE job_id = 3
;

ALTER TABLE job_applied
ADD contact VARCHAR(50)
;

SELECT * FROM job_applied
;

INSERT INTO job_applied VALUES
(4,'2024-03-05', true, 'resume_04.pdf', false, NULL,'submitted'),
(5, '2024-03-11', true, 'resume_05.pdf', true, 'cover_letter_03', 'submitted')
;

UPDATE job_applied SET cover_letter_file_name = 'cover_letter_03.pdf' WHERE job_id = 5
;

UPDATE job_applied SET contact = 'Arthur Morgan' WHERE job_id = 1
;
UPDATE job_applied SET contact = 'Dutch van der Linde' WHERE job_id = 2
;
UPDATE job_applied SET contact = 'John Marston' WHERE job_id = 3
;
UPDATE job_applied SET contact = 'Hosea Matthews' WHERE job_id = 4
;
UPDATE job_applied SET contact = 'Sadie Adler' WHERE job_id = 5
;

ALTER TABLE job_applied RENAME COLUMN contact TO contact_name
;

ALTER TABLE job_applied 
ALTER COLUMN contact_name TYPE TEXT
;