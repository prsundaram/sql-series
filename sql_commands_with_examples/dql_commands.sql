-- ===========================================================
-- DQL COMPLETE REFERENCE FOR `students` TABLE
-- ===========================================================
-- Table: students
-- Columns:
--   id (INT, AUTO_INCREMENT, Primary Key)
--   student_name (VARCHAR) → name of the student
--   city (VARCHAR)         → city of residence
--   age (INT)              → student’s age

-- ===========================================================
-- BASIC SELECTS
-- ===========================================================

-- Fetch all rows and columns (not recommended in production, but useful for quick checks).
SELECT * FROM students;

-- Fetch specific columns and rename them using AS (aliases improve readability in reports).
SELECT student_name AS "Name of Student", city AS "City" FROM students;

-- ===========================================================
-- FILTERING WITH WHERE
-- ===========================================================

-- Equality filter: only students from Chennai.
SELECT * FROM students WHERE city = 'Chennai';

-- Not equal filter: students not from Delhi.
SELECT * FROM students WHERE city <> 'Delhi';

-- Comparison operators: students older than 21.
SELECT * FROM students WHERE age > 21;

-- BETWEEN operator: age between 20 and 22 (inclusive).
SELECT * FROM students WHERE age BETWEEN 20 AND 22;

-- IN operator: students from Chennai, Delhi, or Mumbai.
SELECT * FROM students WHERE city IN ('Chennai','Delhi','Mumbai');

-- ===========================================================
-- PATTERN MATCHING
-- ===========================================================

-- LIKE operator: name contains 'Sundar'.
SELECT student_name FROM students WHERE student_name LIKE '%Sundar%';

-- LIKE starts with 'An'.
SELECT student_name FROM students WHERE student_name LIKE 'An%';

-- LIKE with single-character wildcard (_).
-- Example: matches names where 2nd character is 'eena' → "Meena Sundaram".
SELECT student_name FROM students WHERE student_name LIKE '_eena%';

-- ===========================================================
-- SORTING & PAGINATION
-- ===========================================================

-- ORDER BY age ascending.
SELECT student_name, age FROM students ORDER BY age;

-- ORDER BY multiple: first sort by age descending, then by name ascending (tie-breaker).
-- Primary sort: age DESC → highest age first, lowest last.
-- Secondary sort (tie-breaker): student_name ASC → alphabetical order within same age.
SELECT student_name, age FROM students ORDER BY age DESC, student_name;

-- LIMIT: first 5 rows (ordered by id for consistency).
SELECT *FROM students ORDER BY id
LIMIT 5;

-- LIMIT + OFFSET: skip 5 rows, show next 5 (rows 6–10).
SELECT *FROM students ORDER BY id
LIMIT 5 OFFSET 5;

-- ===========================================================
-- DISTINCT VALUES
-- ===========================================================

-- DISTINCT: list unique cities (no duplicates).
SELECT DISTINCT city FROM students;

-- COUNT(DISTINCT): number of unique cities.
SELECT COUNT(DISTINCT city) AS unique_cities FROM students;

-- ===========================================================
-- AGGREGATES
-- ===========================================================

-- COUNT: total number of students.
SELECT COUNT(*) AS total_students FROM students;

-- AVG, MIN, MAX: calculate average, youngest, and oldest ages.
SELECT AVG(age) AS avg_age, MIN(age) AS youngest, MAX(age) AS oldest FROM students;

-- ===========================================================
-- GROUP BY & HAVING
-- ===========================================================

-- GROUP BY: number of students per city.
SELECT city, COUNT(*) AS num_students FROM students GROUP BY city;

-- GROUP BY with AVG: average age per city.
SELECT city, AVG(age) AS avg_age FROM students GROUP BY city;

-- HAVING: filter groups (only cities with more than 1 student).
SELECT city, COUNT(*) AS cnt FROM students GROUP BY city HAVING COUNT(*) > 1;

-- ===========================================================
-- SUBQUERIES
-- ===========================================================

-- Scalar subquery: fetch student(s) with maximum age.
SELECT student_name, age FROM students WHERE age = (SELECT MAX(age) FROM students);

-- IN-subquery: fetch students with ages that appear more than once.
SELECT student_name, age FROM students
WHERE age IN (SELECT age FROM students GROUP BY age HAVING COUNT(*) > 1);

-- Correlated subquery: students older than their city’s average age.
SELECT s.student_name, s.city, s.age
FROM students s
WHERE s.age > (SELECT AVG(age) FROM students WHERE city = s.city);

-- ===========================================================
-- COMMON TABLE EXPRESSIONS (CTE)
-- ===========================================================

-- CTE: compute city averages, then select students older than that average.
WITH city_avg AS (
  SELECT city, AVG(age) AS avg_age FROM students GROUP BY city
)
SELECT s.student_name, s.city, s.age, ca.avg_age
FROM students s
JOIN city_avg ca ON s.city = ca.city
WHERE s.age > ca.avg_age;

-- ===========================================================
-- SELF-JOIN
-- ===========================================================

-- Self-join: find pairs of students with the same age (avoid duplicates with id <).
SELECT s1.student_name AS student1, s2.student_name AS student2, s1.age
FROM students s1
JOIN students s2 ON s1.age = s2.age AND s1.id < s2.id;

-- ===========================================================
-- WINDOW FUNCTIONS
-- ===========================================================

-- RANK: assign rank based on age (ties get same rank, gaps after ties).
-- RANK() is a window function that assigns a rank to each row based on the ordering you specify (ORDER BY).
-- Tied values (same ORDER BY value) get the same rank.
-- BUT → the next rank is skipped depending on how many ties there were.
SELECT student_name, age, RANK() OVER (ORDER BY age DESC) AS rank_age FROM students;

-- DENSE_RANK: like RANK but no gaps.
-- DENSE_RANK() is a window function that assigns a rank to each row based on the ordering you specify.
-- Tied values (same ORDER BY column) get the same rank.
-- Unlike RANK(), no gaps appear in the ranking sequence.
-- Example:
--   If Chennai has 3 students aged 24, 22, 21 → their ranks will be 1, 2, 3.
--   If 2 of them have the same age, they’ll share a rank, and the next rank will be skipped.
SELECT student_name, age, DENSE_RANK() OVER (ORDER BY age DESC) AS dense_rank_age FROM students;

-- ROW_NUMBER: assign unique row numbers regardless of ties.
SELECT student_name, age, ROW_NUMBER() OVER (ORDER BY age DESC, student_name) AS rn FROM students;

-- PARTITION BY: rank students within each city.
-- Rank students within each city based on age (highest age = rank 1).
-- PARTITION BY city → ranking starts fresh for every city.
-- ORDER BY age DESC → older students get smaller rank numbers.
-- RANK() → same age = same rank, but the next rank will skip numbers.
SELECT city, student_name, age,
       RANK() OVER (PARTITION BY city ORDER BY age DESC) AS city_rank
FROM students;

-- NTILE: split into 4 buckets (quartiles) based on age.
SELECT student_name, age, NTILE(4) OVER (ORDER BY age DESC) AS quartile FROM students;

-- LAG/LEAD: access previous and next row’s age values.
SELECT student_name, age,
       LAG(age) OVER (ORDER BY age DESC) AS prev_age,
       LEAD(age) OVER (ORDER BY age DESC) AS next_age
FROM students;

-- Running total: cumulative sum of ages in descending order.
-- Running total of ages (cumulative sum).
-- Idea: Take each row in age order (DESC) and keep adding the ages as we go down.
-- SUM(age) OVER (...) → window function to calculate cumulative total.

SELECT student_name, age,
       SUM(age) OVER (
         ORDER BY age DESC                      -- Step 1: sort by age highest → lowest
         ROWS BETWEEN UNBOUNDED PRECEDING       -- Step 2: start from the first row (top)
              AND CURRENT ROW                   -- Step 3: go till the current row, So, for each student, SQL adds all ages from the top row till that row.
       ) AS running_total_age
FROM students;


-- ===========================================================
-- SET OPERATIONS
-- ===========================================================

-- UNION: combine results, remove duplicates.
SELECT student_name, city FROM students WHERE city = 'Chennai'
UNION
SELECT student_name, city FROM students WHERE age > 23;

-- UNION ALL: combine results, keep duplicates.
SELECT student_name FROM students WHERE city = 'Delhi'
UNION ALL
SELECT student_name FROM students WHERE age = 20;

-- ===========================================================
-- STRING & NUMERIC FUNCTIONS
-- ===========================================================

-- String functions: uppercase, lowercase, length, concatenation.
SELECT UPPER(student_name) AS name_upper,
       LOWER(student_name) AS name_lower,
       CHAR_LENGTH(student_name) AS name_len,
       CONCAT(student_name, ' (', city, ')') AS display
FROM students;

-- Numeric functions: modulo, absolute difference.
SELECT id, age, MOD(age, 2) AS age_mod_2, ABS(age - 21) AS diff_from_21 FROM students;

-- ===========================================================
-- NULL HANDLING
-- ===========================================================

-- COALESCE: replace NULL with a fallback (here, city defaults to 'Unknown').
SELECT student_name, COALESCE(city, 'Unknown') AS city_or_unknown FROM students;

-- IFNULL: MySQL-specific shortcut for COALESCE.
SELECT student_name, IFNULL(city, 'No City') AS safe_city FROM students;

-- NULL-safe equality (MySQL <=> operator).
SELECT * FROM students WHERE city <=> NULL;

-- ===========================================================
-- CASE EXPRESSIONS
-- ===========================================================

-- CASE: categorize students into age groups.
SELECT student_name, age,
  CASE
    WHEN age <= 20 THEN 'Young'
    WHEN age BETWEEN 21 AND 23 THEN 'Early 20s'
    WHEN age >= 24 THEN 'Mid 20s+'
  END AS age_group
FROM students;

-- ===========================================================
-- DERIVED TABLE
-- ===========================================================

-- Derived table: compute avg age by city inline, then filter students above avg.
-- Derived table example:
-- Goal: Find students whose age is above the average age of their city.

SELECT t.city, t.avg_age, s.student_name, s.age
FROM (
        -- Step 1: Create a small temporary table (derived table)
        -- It calculates average age per city.
        SELECT city, AVG(age) AS avg_age
        FROM students
        GROUP BY city
     ) t                           -- give this derived table an alias 't'
JOIN students s                    -- Step 2: join original students table
     ON s.city = t.city            -- match city from students with city from derived table
WHERE s.age > t.avg_age;           -- Step 3: filter only those students older than city average


-- ===========================================================
-- ADVANCED CHALLENGES
-- ===========================================================

-- Top student per city (highest age, tie-break by name).
SELECT city, student_name, age
FROM (
       -- Step 1: Inside subquery, assign row numbers within each city
       SELECT city, student_name, age,
              ROW_NUMBER() OVER (
                   PARTITION BY city                  -- restart numbering for each city
                   ORDER BY age DESC, student_name -- order: highest age first,
                                                     -- if same age, use name A→Z
              ) AS rn
       FROM students
     ) t
WHERE rn = 1; -- Step 2: pick only the first row (rank 1) per city


-- Top 25% by age (using NTILE).
-- Split students into 4 groups (quartiles) by age
-- Example 20 ÷ 4 = 5 rows per group.
-- So:
-- Quartile 1 = 5 oldest students
-- Quartile 2 = next 5
-- Quartile 3 = next 5
-- Quartile 4 = 5 youngest students
SELECT student_name, age
FROM (
  SELECT student_name, age, NTILE(4) OVER (ORDER BY age DESC) AS quart
  FROM students
) q
WHERE quart = 1;

-- Running count of rows (cumulative).
SELECT student_name, age,
       COUNT(*) OVER (ORDER BY age DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_count
FROM students;
