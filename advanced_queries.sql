COPY company_dim
FROM 'C:\Users\Public\lukeb_sql\csv_files\company_dim.csv'
DELIMITER ',' CSV HEADER
;

COPY job_postings_fact
FROM 'C:\Users\Public\lukeb_sql\csv_files\job_postings_fact.csv'
DELIMITER ',' CSV HEADER
;

COPY skills_dim
FROM 'C:\Users\Public\lukeb_sql\csv_files\skills_dim.csv'
DELIMITER ',' CSV HEADER
;

COPY skills_job_dim
FROM 'C:\Users\Public\lukeb_sql\csv_files\skills_job_dim.csv'
DELIMITER ',' CSV HEADER
;


CREATE TABLE january_jobs as 
    SELECT * FROM job_postings_fact 
    where EXTRACT(MONTH from job_posted_date) = 1
;

CREATE TABLE february_jobs as 
    SELECT * FROM job_postings_fact 
    where EXTRACT(MONTH from job_posted_date) = 2
;

CREATE TABLE march_jobs as 
    SELECT * FROM job_postings_fact 
    where EXTRACT(MONTH from job_posted_date) = 3
;


SELECT count(job_id),
    case 
        when job_location = 'Anywhere' then 'Remote'
        when job_location = 'New York, NY' then 'Local'
        else 'Onsite'
    end as location_category
from job_postings_fact
where job_title_short = 'Data Analyst'
GROUP BY location_category
;


SELECT
    company_id,
    name FROM company_dim
where company_id in (
    SELECT company_id from job_postings_fact
    where job_no_degree_mention = true
)
;


with company_job_count as (
    SELECT company_id, count(*) as total_jobs 
    from job_postings_fact
    group by company_id
)
SELECT company_dim.name as company_name,
        company_job_count.total_jobs 
FROM company_dim
left join company_job_count 
    on company_job_count.company_id = company_dim.company_id
order by total_jobs desc
;


SELECT
    job_title_short,
    company_id,
    job_location
from 
    january_jobs

UNION all

SELECT
    job_title_short,
    company_id,
    job_location
from 
    february_jobs

UNION all

SELECT
    job_title_short,
    company_id,
    job_location
from 
    march_jobs
;