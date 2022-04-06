-- Postgresql Hard-disk Mechanism

-- Shows where postgres is stored in the disk
SHOW data_directory;

-- Shows the internal identifiers and data name of postgres databases in disk
SHOW oid, datname
FROM pg_database;

-- Shows information about database objects from the store
SHOW * FROM pg_class;

-- Heap or Heap File: File that contains all the data (rows) of our table

-- Tuple or Item: Individual row from the table

-- Block or Page: The heap is divided into many different blocks/pages. 
-- Each block/page store some number of rows and are by default 8kb in size.
-- A block stores binary data on the hard disk and stores data in sections.
-- The first section stores information about the block.
-- The second section stores information about the the rows.
-- The third section is a free space which stores collections of user data.
-- The last section stores information in the tuples and rows. 

-- A Full Table Scan is when Postgres loads up all the rows in a heap file to 
-- the memory of the computer to find a specific piece of data.

-- An index is an alternative to a Full Table Scan. 
-- An index is a data structure that efficiently tells us what block/index
-- a record is stored at in a heap file. 

-- How an Index Works:

-- We specify which column we want to have a fast lookup on. 
-- Extract only the property we want to have a fast lookup by and the block/index
-- for each.
-- Sort the values in the index in a meaningful way.  
-- Organize the sorted values in a tree data structure. Evenly distribute values
-- in the leaf nodes in order left to right.  
-- Searches are done in the tree data structure with an inequality criterion to 
-- efficiently retrieve the the block/index information.  

-- Creating Indexes with custom index names  
CREATE INDEX <tableName_columnName_idx> ON <table_name> (<column_name>);

-- Delete Indexes
DROP INDEX <index_name>; 

-- Benchmarking Queries 
EXPLAIN ANALYZE <Query> 

-- The Execution time in the result of the above query is an appropriate metric 
-- to measure the effiency of a given query. 
-- It is more meaningful to compare the results before an after indexing.

-- Looking Up Storage Space occupied by a (indexed) table or index
SELECT pg_size_pretty(pg_relation_size("<table_name/index_name>"));

-- Indexes takes up more storage space as they hold table/column data and pointers to the
-- blocks/indexes of where they are stored.

-- Types of Indexes:

-- B-Tree index: General purpose index, used 99% of the time
-- Hash Index: Speeds up simple equality checks
-- Gist Index: Geometry, full text search 
-- SP-Gist Index: Clustered data such as such dates - many rows might have the same year
-- GIN Index: For columns that have arrays of JSON data
-- BRIN Index: Specialized for really large datasets

-- Query to show all the indexes in a database
SELECT relname, relkind
FROM pg_class -- pg_class is a postgres table that holds all database objects
WHERE relkind = 'i';

-- An extension is a piece of code that gives us additional functionality in postgres

-- Query to create an extension
CREATE EXTENSION <extension_name>;

-- The pageinspect extension gives us functions that we can use to look at data stored 
-- inside the pages in a heap file.

-- Function to inspect the B-Tree meta page inside an index
SELECT * 
FROM bt_metap('index_name');

-- Function to retrieve the items in a page inside an index
SELECT *
FROM bt_page_items('<index_name', <page_index>);

-- The Query Processing Pipeline

-- Every query goes through the following processing steps:

-- Parser: builds a query tree (programmatic description of query) to carry out lexical analysis.
-- Rewrite: optimizes the query. Decompose views into underlying table references.
-- Planner: Takes the query tree, figures out what information you are trying to fetch and figures
--          out the best strategy or fastest way to get that information.
-- Execution: The executor runs the query.

-- EXPLAIN & EXPLAIN ANALYZE

-- These are for benchmarking and evaluating query performance, not for use in real data fetching 

-- EXPLAIN: builds a query plan and displays some info about it.
-- EXPLAIN ANALYZE: builds a query plan, run it and displays some info about it.

-- The EXPLAIN ANALYZE icon, three icons way from the Execute icon in Pg_Admin, displays a 
-- graphical view of the query plan. It is quite handy to enable all the items in the dropdown  
-- besides the EXPLAIN ANALYZE icon to get a better graphical analysis of the query plan.

-- ANALYZING THE RESULT OF AN EXPLAIN ANALYZE QUERY

-- The result of the query plan contains query nodes indicated by the leading "->".
-- The query nodes emits the info they are accessing to the parent query node.
-- The query nodes includes:
-- Hash Join 
-- Hash
-- Seq Scan
-- Index Scan

-- The output of the hash join is the final result of the query

-- pg_stats is a table where postgres stores statistics about all columns and rows of tables
-- in a database.
SELECT * 
FROM pg_stats
WHERE tablename = '<table_name>'

-- Full Table Scan -> Sequential load 
-- Indexing -> Random load  

-- Random Load takes 4 times longer than a sequential load

-- Processing Formula
-- (#pages) * 1.0 + (#rows) * 0.01

-- Source for cost factors - postgresql.org/docs/current/runtime-config-query.html
-- Cost = ** (#pages read sequentially) * seq_page_cost (Default -> 1.0) +
--        (#pages read at random) * random_page_cost (Default -> 4.0) + 
--        ** (#rows scanned) * cpu_tuple_cost (Default -> 0.1) + 
--        (#index entries scanned) * cpu_index_tuple_cost (Default -> 0.05) + 
--        (#times function/operator evaluated) * cpu_operator_cost (Default -> 0.025)

-- Other cost factors are relative to the seq_page_cost 
