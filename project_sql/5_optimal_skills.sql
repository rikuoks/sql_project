/*
Query using CTE's for most optimal skills to learn / high demand and high paying.
*/

with skills_demand as (
select 
    skills_dim.skill_id,
    skills_dim.skills, 
    count(skills_job_dim.job_id) as demand_count
from job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where   
    job_work_from_home = True and
    job_title_short = 'Data Analyst' and
    salary_year_avg is not null
group by 
    skills_dim.skill_id
),

average_salary as (
select 
    skills_job_dim.skill_id, 
    round(avg(salary_year_avg),0) as avg_salary
from 
    job_postings_fact

INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id

WHERE
    job_title_short = 'Data Analyst'
    and salary_year_avg is not null
    and job_work_from_home = True
    -- and job_location = 'Finland'

group by 
    skills_job_dim.skill_id
order by 
    avg_salary desc 
)

select 
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
from
    skills_demand
INNER JOIN average_salary on skills_demand.skill_id = average_salary.skill_id
order by demand_count desc, average_salary desc
;


/*
More simple version with same results.
*/


SELECT
    skills_dim.skill_id,
    skills_dim.skills,
    count(skills_job_dim.job_id) as demand_count,
    round(avg(job_postings_fact.salary_year_avg),0) as avg_salary
from job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    and salary_year_avg is not null
    and job_work_from_home = True
group by 
    skills_dim.skill_id
HAVING
    count(skills_job_dim.job_id) > 10
order by
    avg_salary desc,
    demand_count desc
limit 20
;