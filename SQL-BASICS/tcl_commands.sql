-- ===========================================================
-- TCL (Transaction Control Language) – Complete SQL Guide
-- Table: students (id AUTO_INCREMENT, student_name, city, age)
-- ===========================================================

-- NOTE: TCL manages transactions (INSERT, UPDATE, DELETE).
-- Commands: START TRANSACTION, COMMIT, ROLLBACK, SAVEPOINT, RELEASE SAVEPOINT, SET TRANSACTION.
-- DDL commands (CREATE, DROP, ALTER) are auto-committed → TCL does not control them.

-- What is TCL?
-- TCL (Transaction Control Language) manages changes made by DML commands (INSERT, UPDATE, DELETE).
-- It controls whether those changes are saved permanently (COMMIT) or undone (ROLLBACK).
-- A Transaction = one or more SQL operations executed as a single logical unit.
	-- Key property = ACID
		-- Atomicity → All or nothing.
		-- Consistency → Database moves from one valid state to another.
		-- Isolation → Transactions don’t interfere.
 -- Durability → Once committed, changes persist even after crash.

-- ===========================================================
-- 1. START TRANSACTION
-- ===========================================================
-- Start a transaction so multiple statements can be treated as a single unit.
-- In MySQL, autocommit is ON by default, so START TRANSACTION is needed.
-- In PostgreSQL → use BEGIN; In Oracle → transaction starts automatically on first DML.

START TRANSACTION;

-- Insert 2 rows (not yet permanent).
INSERT INTO students (student_name, city, age) VALUES ('TCL Student1', 'Chennai', 22);
INSERT INTO students (student_name, city, age) VALUES ('TCL Student2', 'Delhi', 21);

-- If we COMMIT here, both rows will be saved permanently.
-- If we ROLLBACK here, both rows will be undone.

-- ===========================================================
-- 2. COMMIT
-- ===========================================================
-- COMMIT makes all changes in the current transaction permanent.
-- Once committed, you cannot roll them back.

COMMIT;

-- Now TCL Student1 and TCL Student2 are permanently in the table.

-- ===========================================================
-- 3. ROLLBACK
-- ===========================================================
-- Rollback undoes all changes since the last COMMIT.
-- Useful if you inserted/updated/deleted by mistake.

START TRANSACTION;

INSERT INTO students (student_name, city, age) VALUES ('Temp Student1', 'Mumbai', 23);
INSERT INTO students (student_name, city, age) VALUES ('Temp Student2', 'Kolkata', 24);

-- Undo both inserts because mistake found.
ROLLBACK;

-- Both Temp Student1 and Temp Student2 are gone (not committed).

-- ===========================================================
-- 4. SAVEPOINT and ROLLBACK TO SAVEPOINT
-- ===========================================================
-- SAVEPOINT lets you create a checkpoint inside a transaction.
-- You can rollback partially to a savepoint, instead of rolling back the whole transaction.

START TRANSACTION;

-- Insert 1st student
INSERT INTO students (student_name, city, age) VALUES ('Save Stu1', 'Chennai', 20);
SAVEPOINT sp1;  -- mark a checkpoint after 1st insert

-- Insert 2nd student
INSERT INTO students (student_name, city, age) VALUES ('Save Stu2', 'Delhi', 22);
SAVEPOINT sp2;  -- checkpoint after 2nd insert

-- Insert 3rd student
INSERT INTO students (student_name, city, age) VALUES ('Save Stu3', 'Mumbai', 23);

-- Oops, undo last insert only (rollback to sp2).
ROLLBACK TO sp2;

-- Now Save Stu1 and Save Stu2 remain, Save Stu3 is undone.

COMMIT; -- Save Stu1 and Save Stu2 are permanent.

-- ===========================================================
-- 5. RELEASE SAVEPOINT
-- ===========================================================
-- Removes a savepoint so it cannot be used for rollback anymore.

START TRANSACTION;

INSERT INTO students (student_name, city, age) VALUES ('Rel Stu1', 'Chennai', 22);
SAVEPOINT sp1;

INSERT INTO students (student_name, city, age) VALUES ('Rel Stu2', 'Delhi', 23);
SAVEPOINT sp2;

-- Delete savepoint sp1
RELEASE SAVEPOINT sp1;

-- Now only sp2 exists → rollback possible only to sp2
ROLLBACK TO sp2; -- undo Rel Stu2, keep Rel Stu1

COMMIT; -- Rel Stu1 saved, Rel Stu2 undone

-- ===========================================================
-- 6. SET TRANSACTION
-- ===========================================================
-- Configure transaction properties: READ ONLY or READ WRITE.
-- Prevents accidental modifications when you only want to read.

SET TRANSACTION READ ONLY;

-- This SELECT works (read only).
SELECT * FROM students;

-- This INSERT fails because transaction is READ ONLY.
INSERT INTO students (student_name, city, age) VALUES ('Blocked Insert', 'Kolkata', 21);

-- Reset back to normal
SET TRANSACTION READ WRITE;

-- ===========================================================
-- 7. AUTOCOMMIT Behavior
-- ===========================================================
-- MySQL → autocommit = ON by default, so every statement is automatically committed.
-- To use TCL properly, disable autocommit:
-- SET autocommit = 0;

-- PostgreSQL → autocommit OFF by default, use BEGIN to start.
-- Oracle → transaction starts automatically on first DML.

-- ===========================================================
-- 8. BEST PRACTICES
-- ===========================================================
-- 1. Always use transactions for critical operations (like banking).
-- 2. Keep transactions short → avoids locking issues.
-- 3. Use SAVEPOINT in long transactions for safety.
-- 4. Always COMMIT or ROLLBACK explicitly → don’t leave open transactions.
-- 5. Use READ ONLY mode for reports to avoid accidental updates.

-- ===========================================================
-- 9. QUICK SUMMARY
-- ===========================================================
-- START TRANSACTION / BEGIN  → Start a transaction
-- COMMIT                     → Save changes permanently
-- ROLLBACK                   → Undo changes since last commit
-- SAVEPOINT                  → Create a checkpoint
-- ROLLBACK TO savepoint      → Undo changes only till a checkpoint
-- RELEASE SAVEPOINT          → Delete a savepoint
-- SET TRANSACTION            → Configure transaction (READ ONLY / READ WRITE)
-- ===========================================================



-- ===========================================================
-- DCL (Data Control Language) – GRANT / REVOKE / USER / ROLE examples
-- NOTE: DCL controls access and privileges. This is separate from TCL.
-- The examples below use MySQL syntax by default. Postgres / Oracle have slightly different syntax (notes included).
-- ===========================================================

-- =========================
-- 1) Create user (MySQL 8+)
-- =========================
-- Create a new DB user. Change host '%' to a specific host or subnet in production.
CREATE USER 'report_user'@'%' IDENTIFIED BY 'StrongP@ssw0rd!';

-- =========================
-- 2) Grant privileges (basic)
-- =========================
-- Grant read-only access to the students table
GRANT SELECT ON mysql_series.students TO 'report_user'@'%';

-- Grant multiple privileges on a specific table
GRANT SELECT, INSERT, UPDATE ON mysql_series.students TO 'app_user'@'192.168.1.%';

-- Grant all privileges on a database (admin-like)
GRANT ALL PRIVILEGES ON mysql_series.* TO 'admin_user'@'localhost' WITH GRANT OPTION;
-- WITH GRANT OPTION allows the grantee to GRANT these privileges to others (use sparingly).

-- =========================
-- 3) Column-level privileges (MySQL support)
-- =========================
-- Grant SELECT only on specific columns of the students table
GRANT SELECT (student_name, city) ON mysql_series.students TO 'limited_user'@'%';

-- =========================
-- 4) Show granted privileges
-- =========================
-- Check what privileges a user has
SHOW GRANTS FOR 'report_user'@'%';
-- Example output: SHOW GRANTS returns the GRANT statements that implement the user's privileges.

-- =========================
-- 5) Revoke privileges
-- =========================
-- Remove specific privileges from a user
REVOKE INSERT, UPDATE ON mysql_series.students FROM 'app_user'@'192.168.1.%';

-- Remove all privileges and grant option from a user
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'admin_user'@'localhost';

-- =========================
-- 6) Drop user
-- =========================
-- Delete a user (use when cleaning up temporary/test users)
DROP USER 'temp_user'@'%';

-- =========================
-- 7) Roles (recommended for managing groups of privileges)
-- =========================
-- Create a role, grant privileges to the role, then grant role to users
CREATE ROLE read_only;
GRANT SELECT ON mysql_series.* TO read_only;

-- Assign role to user
GRANT read_only TO 'report_user'@'%';

-- Make the role active by default for the user (MySQL 8.0.16+ supports DEFAULT ROLE)
SET DEFAULT ROLE read_only TO 'report_user'@'%';

-- =========================
-- 8) Using roles: revoke / drop role
-- =========================
-- Revoke a role from a user
REVOKE read_only FROM 'report_user'@'%';

-- Drop role (removes role definition)
DROP ROLE read_only;

-- =========================
-- 9) Privilege scopes & types (quick notes)
-- =========================
-- Privileges can be granted at different scopes:
--   * Global:      ON *.*            (applies to entire server)
--   * Database:    ON mysql_series.* (applies to all tables in this DB)
--   * Table:       ON mysql_series.students
--   * Column:      ON mysql_series.students(column)
--   * Routine:     ON PROCEDURE/FUNCTION
--
-- Common privilege types: SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, EXECUTE, GRANT OPTION, etc.

-- =========================
-- 10) MySQL notes about FLUSH PRIVILEGES
-- =========================
-- Historically, after manual changes to mysql.user you needed:
--   FLUSH PRIVILEGES;
-- But GRANT/REVOKE/CREATE USER/ DROP USER automatically reload privileges — FLUSH rarely needed when using GRANT/REVOKE.

-- =========================
-- 11) Postgres / Oracle differences (quick)
-- =========================
-- PostgreSQL example:
--   CREATE ROLE report_user WITH LOGIN PASSWORD 'pwd';
--   GRANT SELECT ON TABLE public.students TO report_user;
--   -- Show grants: \du or query pg_catalog tables.
--
-- Oracle notes:
--   CREATE USER report_user IDENTIFIED BY pwd;
--   GRANT SELECT ON schema.students TO report_user;
--   -- Oracle uses roles and profiles, and GRANT syntax is similar but slightly different.

-- =========================
-- 12) Best practices (security & ops)
-- =========================
-- 1) Principle of Least Privilege: grant only required privileges, avoid ALL unless necessary.
-- 2) Use roles/groups for easier privilege management (assign privileges to roles, then roles to users).
-- 3) Avoid using '%' (any host) in production; bind users to specific host/IP or range.
-- 4) Do not give WITH GRANT OPTION to application users — restrict to DB admins.
-- 5) Rotate credentials, enforce strong passwords, and use SSL/TLS for DB connections.
-- 6) Audit privilege grants (log SHOW GRANTS, or query information_schema.user_privileges).
-- 7) Use separate users for app vs reporting vs admin duties to limit blast radius.
-- 8) Regularly review and revoke unused privileges.

-- =========================
-- 13) Example: common workflows
-- =========================
-- Workflow: Create reporting user with read-only access
CREATE USER 'reporting'@'10.0.0.%' IDENTIFIED BY 'R3p0rt!';
GRANT SELECT ON mysql_series.* TO 'reporting'@'10.0.0.%';

-- Workflow: Create app user with limited DML rights on students table only
CREATE USER 'app_service'@'10.0.0.10' IDENTIFIED BY 'AppS3rv!c3P@ss';
GRANT SELECT, INSERT, UPDATE ON mysql_series.students TO 'app_service'@'10.0.0.10';

-- When done testing, drop user
DROP USER 'some_temp_user'@'%';

-- =========================
-- 14) Audit helpers
-- =========================
-- Query privileges from information_schema (MySQL)
SELECT * FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE LIKE "'report_user'%";

-- Or list grants per user
SHOW GRANTS FOR 'reporting'@'10.0.0.%';

-- ===========================================================
-- End of DCL section
-- ===========================================================

