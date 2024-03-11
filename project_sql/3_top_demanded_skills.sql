/*
Top demanded skills for Data Analyst.
*/

with remote_job_skills as (
    SELECT
        skill_id,
        count(*) as skill_count
    FROM
        skills_job_dim as skills_to_job
    INNER JOIN job_postings_fact as job_postings 
        on job_postings.job_id = skills_to_job.job_id
    where
        job_postings.job_work_from_home = True and
        job_postings.job_title_short = 'Data Analyst'
    group by 
        skill_id
)

select 
    skills.skill_id,
    skills as skill_name,
    skill_count
from remote_job_skills
INNER JOIN skills_dim as skills on skills.skill_id = remote_job_skills.skill_id
order by skill_count desc
limit 5
;


/*
Top demanded skills overall with slightly different kind of query. 
Location set to 'Finland'
*/

select 
    skills, 
    count(skills_job_dim.job_id) as demand_count
from 
    job_postings_fact
INNER JOIN skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
where 
    job_location = 'Finland'
group by 
    skills 
order by 
    demand_count desc 
limit 15
;