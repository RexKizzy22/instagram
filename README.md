# INSTAGRAM

Instagram is a documentation of a use-case for **SQL** and **PostgreSQL**.

It covers some considerations and topics such as:
- Advance SQL queries
- Schema Design tool
- Advance Query tuning
- Managing Database Design and Schema migration
- Common Table Expressions (Simple and Recursive)
- Simplyfying Queries with Views
- Optimizing Queries with Materialized Views 
- Handling Concurrency and Reversibility with Transactions
- The Repository pattern for accessing data in PostgreSQL
- Accessing PostgreSQL with Node APIs
- Security around PostgreSQL
- Fast Parallel Testing

### IMPORTANT NOTES
- Transactions usually create lock conditions such that **UPDATES** cannot
    take effect until a transaction is committed.
- A **pg** API client can only run one query at a time but a **pg** pool 
    internally maintains several different clients to run concurrent queries.
    These clients can be reused by the pool as well. 
- A **pg** client **must** be used to run a transaction.
- A pool connection does not make contact with the Postgres database until a client is created.
- Running a query with the **pool** object is an asynchronus operation.
    A client is created and contact is made when a query is ran.
- For data migrations: 
    - create a data directory inside the migrations directory
    - name the data migration files using a convention that indicates they were run
        in a chronological order
    - the files should contain the a pool connection and the migration query 
- To run the migration command `pnpm migrate up/down` using the **node-pg-migrate** package,
    bind the database URI string to a `DATABASE_URI` variable.
    (`DATABASE_URI=postgres://<USER>@localhost:5432/<DATABASE_NAME> pnpm migrate up/down`)
- Useful dependencies to consider when accessing PostgreSQL with Node API in an application include: 
    - **dedent**
    - **pg** 
    - **node-pg-migrate**
    - **pg-format**
    - **supertest**
    - **jest**
    - **express**
    - **nodemon**
