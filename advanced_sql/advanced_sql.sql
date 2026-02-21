-------soal 1
SELECT 
    ROUND(AVG(salary_year_avg)) as rata_gaji_tahunan,
    ROUND(AVG(salary_hour_avg)) as rata_gaji_perjam,
    job_schedule_type
FROM 
    job_postings_fact
WHERE  
    job_posted_date::DATE > '2023-06-01'
GROUP BY
    job_schedule_type
-------soal 2
SELECT 
    COUNT(job_id),
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS MONTH
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') = 2023 
GROUP BY
    MONTH
ORDER BY
    MONTH;
------soal 3
SELECT 
    cd.name
FROM    
    company_dim AS cd
INNER JOIN job_postings_fact AS jpf
    ON jpf.company_id = cd.company_id
WHERE
    (jpf.job_health_insurance IS TRUE) AND EXTRACT(QUARTER FROM jpf.job_posted_date) = 2
    AND (EXTRACT(YEAR FROM jpf.job_posted_date)) = 2023

-----practice problem 6 creating table dari table lainnya

CREATE TABLE january_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE february_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE march_jobs AS
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

--------------- case expression 

SELECT 
    CASE 
        WHEN job_location = 'Anywhere' THEN  'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE  'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category
ORDER BY number_of_jobs DESC
--------------------------PRACTICE
SELECT 
    COUNT(job_id) as total_jobs,
    CASE 
        WHEN salary_year_avg < 60000 THEN 'Low Income' 
        WHEN salary_year_avg >=60000 AND salary_year_avg < 100000 THEN 'Middle Income'
        ELSE  'High Income'
    END AS Income_category   
FROM job_postings_fact
WHERE job_title = 'Data Analyst' 
GROUP BY 
    income_category
ORDER BY total_jobs DESC
--------------SUBQUERIES

SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN(
    SELECT 
        company_id
    FROM 
        job_postings_fact
    WHERE 
        job_no_degree_mention = true 
    ORDER BY 
        company_id
)
------CTE (common table expression) table sementara, biasanya untuk join join dadakan
WITH company_job_count AS(
    SELECT
        company_id,
        COUNT(*) as counter
    FROM job_postings_fact
    GROUP BY 
        company_id

)
SELECT 
    name as nama_perusahaan,
    company_job_count.counter as jumlah_pekerjaan
FROM company_dim as cd
LEFT JOIN company_job_count
ON company_job_count.company_id = cd.company_id
ORDER BY 
    jumlah_pekerjaan DESC

--------- soal latihan sub querty dan cte 1
SELECT 
    sd.type,
    sub.total_mentions
FROM (
    SELECT 
        skill_id,
        COUNT(job_id) AS total_mentions
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY total_mentions DESC
    LIMIT 5
)AS  sub
JOIN skills_dim AS sd
    ON sub.skill_id = sd.skill_id
ORDER BY sub.total_mentions DESC;


-------------soal latihan sub query 2
SELECT
    company_post.names,
CASE 
    WHEN hitung < 10 THEN 'Small Company' 
    WHEN hitung >= 10 and hitung <= 50 THEN 'Medium Company' 
    ELSE 'Large Company'
END company_size
FROM (
    SELECT      
    cd.name as names,
    COUNT(jpf.job_id) as hitung
    FROM job_postings_fact as jpf
    JOIN company_dim as cd
    ON jpf.company_id = cd.company_id
    GROUP BY cd.name
) AS company_post;


-----------Practice Problem 7 non cte

SELECT sd.skill_id as id_skill, sd.skills as nama_skill , COUNT(jpf.job_id) as total_pekerjaan

FROM job_postings_fact as jpf
INNER JOIN skills_job_dim as sjd
ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim as sd
ON sjd.skill_id = sd.skill_id

WHERE jpf.job_work_from_home = True
GROUP BY id_skill
ORDER BY total_pekerjaan desc
LIMIT 5
---------Practice Problem With CTE 
WITH remote_job_skills AS (
    SELECT
        skill_id,
        COUNT(*) AS total_needs
    FROM 
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS jpf ON skills_to_job.job_id = jpf.job_id
    WHERE jpf.job_work_from_home = True 
    GROUP BY
        skill_id
)

SELECT 
    sd.skill_id as id,
    sd.skills as nama_skill,
    remote_job_skills.total_needs 
FROM skills_dim as sd 
INNER JOIN remote_job_skills ON sd.skill_id = remote_job_skills.skill_id
ORDER BY total_needs DESC
limit 5 

---------UNION & UNION ALL
SELECT
    job_title_short,
    company_id,
    job_location
FROM january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM february_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM february_jobs

-------- Practice Problem UNION
    
WITH Q1 AS(
    SELECT *
    FROM january_jobs

    UNION 

    SELECT *
    FROM february_jobs

    UNION 

    SELECT *
    FROM march_jobs
)

SELECT 
    sd.skills as skill,
    sd.type as tipe_skill
FROM Q1 
LEFT JOIN  skills_job_dim  as sjd ON sjd.job_id = Q1.job_id
LEFT JOIN skills_dim as sd ON sjd.skill_id = sd.skill_id
WHERE Q1.salary_year_avg > 70000

-----------Practice Problem 8   
SELECT
    q1.job_title_short,
    q1.job_location,
    q1.job_via,
    q1.job_posted_date::DATE,
    q1.salary_year_avg 
FROM(
    SELECT *
    FROM january_jobs
    UNION ALL
    SELECT *
    FROM february_jobs
    UNION ALL
    SELECT *
    FROM march_jobs
) AS q1
WHERE q1.salary_year_avg > 70000
    AND q1.job_title_short = 'Data Analyst'
ORDER BY 
    q1.salary_year_avg desc
