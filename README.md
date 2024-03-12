### In progress - ToDo list - 2024-03-12
- Charts and visualizations for analyses
- Visual tables for aggregated functions
- Improvement of the documentation

## Introduction
Project for analysing data driven job markets. Focusing mainly on Data Analyst roles in Finland. Looking for high demand and highly paid data jobs. Queries used in the project can be found here: [project_sql](/project_sql/)

Visualization in progress...

## Background
Educational project from SQL course by Luke Barousse. 
Source files: 
- lukeb.co/sql_project_csvs
- lukeb.co/sql_jobs_db
- lukeb.co/sql_invoices_db


### The questions for analysis
1. top paying jobs
2. top paying job skills
3. top demanded skills
4. top paying skills
5. optimal skills

## Tools I Used
1. SQL
2. PostgreSQL
3. VSCode
4. Git & GitHub

## The Analysis
### 1. top paying jobs
What are the top paying jobs for Data Analyst role in Finland?
Instead of focusing on job postings with specified salaries, 
'salary_year_avg' and 'limit' are ignored for more local results.

```sql
select
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
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
;
```

### 2. top paying job skills
Query for local jobs of interest for Data Analyst. Using without the 'where' clause in
second query and adding the 'salary_year_avg' we can observe broader skills in demand with yearly average salaries etc.

```sql
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
```

### 3. top demanded skills
Top demanded skills for Data Analyst.
```sql
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
```
Top demanded skills overall with slightly different kind of query. 
Location set to 'Finland'
```sql

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
```

### 4. top paying skills
Query for finding out the top skills based on average salary. 
'where' clause includes an argument used for remote or local.
```sql
select 
    skills, 
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
    skills 
order by 
    avg_salary desc 
limit 55
;
```
### 5. optimal skills
Query using CTE's for most optimal skills to learn / high demand and high paying.
```sql
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
```
More simple version with same results.
```sql
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
```
## What I Learned
Learned to use PostgreSQL in VSCode and to create a GitHub repository using Git. In SQL point of view I strengthened my skills to use JOINs and CTE's aswell as other basic SQL functions. In regards of the source material, there is high demand for SQL and Python skilled people on Data Analyst jobs. 

## Conclusions
In this project we deep dived into a data driven job markets. Answering to 5 key questions about which Data Analyst skills are in high demand and also with the highest salaries. It turned out that SQL, Python, Excel and Power BI are some of the most sought after skill sets in data analytics field.