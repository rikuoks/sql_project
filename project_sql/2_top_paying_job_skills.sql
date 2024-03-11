/*
Query for local jobs of interest for Data Analyst. Using without the 'where' clause in
second query and adding the 'salary_year_avg' we can observe broader skills in demand with 
yearly average salaries etc.
*/

with jobs_of_interest as (
    select
        job_id,
        job_title,
        -- salary_year_avg,
        name as company_name
    from 
        job_postings_fact

    left join company_dim 
        on job_postings_fact.company_id = company_dim.company_id

    where job_title_short = 'Data Analyst' and 
            job_location = 'Finland' -- and salary_year_avg is not null

    order by 
    salary_year_avg desc 

    -- limit 10
)

select jobs_of_interest.*,
        skills 
from jobs_of_interest
INNER JOIN skills_job_dim on jobs_of_interest.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
-- where skills = 'sql' or skills = 'excel' or skills = 'python' or skills = 'power bi'
where skills in ('sql','excel','python','power bi')
-- order by salary_year_avg DESC
;