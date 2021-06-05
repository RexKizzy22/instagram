-- Common Table Expressions.

-- Defined with a "WITH" keyword before the main query.
-- Produces a table that we can refer to anywhere else.
-- They are of two forms:
-- Simple form: used to make a query easier to understand
-- Reacursive form: used to write queries that are otherwise impossible to write

-- Question
-- Show the username of users that were tagged in a caption or photo before
-- January 7th, 2010. Also, show the date they are tagged 

-- Simple form
--           Before 
SELECT username, tags.created_at
FROM users
JOIN 
    (
        SELECT user_id, created_at FROM caption_tags 
        UNION ALL
        SELECT user_id, created_at FROM photo_tags
    ) AS tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';

--          After 
WITH tags AS (
    SELECT user_id, created_at FROM caption_tags 
    UNION ALL
    SELECT user_id, created_at FROM photo_tags
) 
SELECT username, tags.created_at
FROM users
JOIN tags ON tags.user_id = users.id 
WHERE tags.created_at < '2010-01-07';

-- Recursive form. 
-- They are very different from simple CTE's.
-- Recursive CTE's are useful anytime you have a tree or graph-type data structure or hierachy.
-- Must use a "UNION" keyword. Simple CTE's don't have to use a "UNION" keyword.

-- Example
WITH RECURSIVE coutdown(val) AS (
    SELECT 3 AS val
    UNION
    SELECT val - 1 FROM coutdown WHERE val > 1
)
SELECT *
FROM coutdown;

-- Anatomy of a Recursive CTE.
-- The subquery above the "UNION" is called the Inital or Non-Recursive query.
-- The subquery after the "UNION" is called the Recursive query.

-- Mechanics of a Recursive CTE.
-- 1. Define results and working tables.
-- 2. Run the non-initial recursive statement, put the results into the results and 
--    working tables.
-- 3. Run the recursive statement replacing the table name 'countdown' with a 
--    reference to the working table.
-- 4. If recursive statement returns some rows, append the result to the results table
--    and run recursion again.
-- 5. If recursive statement returns no rows, stop the recursion.

-- A use case for a recursive CTE is to recommend who to follow in a follower system
-- in a social media app. That is, the leaders of a leader and so on.
WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
        SELECT leader_id, follower_id, 1 AS depth
        FROM followers
        WHERE follower_id = 1000
    UNION
        SELECT followers.followers.leader_id, followers.follower_id, depth + 1
        FROM followers
        JOIN suggestions ON suggestions.leader_id = suggestions.follower_id
        WHERE depth < 3
)
SELECT DISTINCT users.id, users.username
FROM suggestions
JOIN users ON users.id = suggestions.leader_id
WHERE depth > 1
LIMIT 30;

-- Miscellaneous.

-- Question.
-- Show the mosr popular users - the users who were tagged the most
SELECT username, COUNT(*)
FROM users
JOIN 
    (
        SELECT user_id FROM photo_tags
        UNION ALL 
        SELECT user_id FROM caption_tags
    ) AS tags ON tags.user_id = users.id
GROUP BY username
ORDER BY COUNT(*) DESC;

-- Copy all rows from one table to another (photo_tags -> tags)
INSERT INTO tags (created_at, updated_at, user_id, post_id, x, y)
SELECT created_at, updated_at, user_id, post_id, x, y 
FROM photo_tags

-- VIEWS.
-- Views are fake tables that has rows from other tables.
-- CTE's can only be referenced to by the query they are attached to.
-- These are exact rows as they exist on other tables, or computed values.
-- We can reference a view in any place where we'd normally reference a table.
-- Views don't actually create any table or move data around. 
-- They don't have to be used for a union. Can compute absolutely any values.
-- Views solve the problem of repeating union queries too frequently which indicates 
-- poor database design or the union of two tables is frequently queried.
-- Views make potentially frequently run subqueries reuseable by storing the result once.

CREATE VIEW tags AS (
    SELECT created_at, user_id, post_id, 'photo_tag' AS type FROM photo_tags
    UNION ALL
    SELECT created_at, user_id, post_id, 'caption_tag' AS type FROM caption_tags
);

-- Use Cases for VIEWS.
-- Given that the most 10 recent posts are really important!
-- We would like to:
-- show the users who created the 10 most recent posts.
-- show the users who were tagged in the 10 most recent posts.
-- show the average number of hashtags used in the 10 most recent posts.
-- show the number of likes each of the 10 most recent posts received.
-- show the hashtags used by the 10 most recent posts.
-- show the total number of comments the 10 most recent posts received.

-- We would rather create a view of the 10 most recent posts than write a subquery
-- retrieving the most recent posts.
CREATE VIEW recent_posts AS (
    SELECT * 
    FROM posts
    ORDER BY created_at DESC  
    LIMIT 10;
);

-- If we wanted to change this view to take account of the 15 most recent posts,
-- we would run the following query.
CREATE OR REPLACE VIEW recent_posts AS (
    SELECT * 
    FROM posts
    ORDER BY created_at DESC  
    LIMIT 15;
);

-- To delete the recent_posts view 
DROP VIEW recent_posts;

-- Materialized VIEWS
-- These are queries that get executed only at specific times, but the results are 
-- saved and can be referenced without rerunning the query.
-- Materialized views are used to save the values of expensive queries so as to 
-- boost performance/efficiency in subsequent reuse.

-- Use Cases for Materialized VIEWS. 

-- Question. 
-- For each week, show the amount of likes that posts and comments received. Use the
-- post and comment created_at date, not when the post was received.  

CREATE MATERIALIZED VIEW weekly_likes AS (
    SELECT 
        date_trunc('week', COALESCE(posts.created_at, comment.created_at)) AS week,
        COUNT(comment.id) AS num_likes_for_comments
        COUNT(posts.id) AS num_likes_for_posts
    FROM likes 
    LEFT JOIN posts ON likes.post_id = posts.id
    LEFT JOIN comments ON likes.comment_id = comments.id
    GROUP BY week
    ORDER BY week
) WITH DATA;

-- Updates to the tables in a materialized view does not reflect in the materialized view.
-- The following query shows how to make postgres make the updates reflect in the MV.
REFRESH MATERIALIZED VIEW weekly_likes;

-- Primary difference between a View and a Materialized Views.
-- Both View and a Materialized View wrap up a query. When you refer to a view, the query
-- is executed. When you refer to a Materialized View, you get back the result of when the
-- materialized view was created or last refreshed.


-- Transactions. 
BEGIN; -- opens up a transaction.
COMMIT; -- closes the transaction.
ROLLBACK; -- reverts back to the main pool or primary source in the following conditions:
             -- when an error is made during a transaction. Revert back manually.
             -- when there is lose of connection in a transaction. Postgres rolls back
             -- automatically. 
             -- when the transaction enters an error state. A roll back is necessary.

