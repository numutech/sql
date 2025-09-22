-- =================================================================
--  Database Setup Script for cricket_db
--  Description: Drops and recreates the database, creates the 
--               players table, grants bulk operation permissions
--               for a Windows user, and loads data from a CSV.
-- =================================================================

-- Switch to the master database to perform server-level operations
USE master;
GO

-- Grant the necessary permission to your Windows login.
-- ============================ IMPORTANT ============================
-- !! REPLACE [Your-Windows-Login-Goes-Here] WITH YOUR ACTUAL LOGIN !!
-- You can find it by running: SELECT SUSER_SNAME();
-- Example: GRANT ADMINISTER BULK OPERATIONS TO [MY-LAPTOP\JohnDoe];
-- ===================================================================
PRINT 'Granting ADMINISTER BULK OPERATIONS permission...';
GRANT ADMINISTER BULK OPERATIONS TO [Your-Windows-Login-Goes-Here];
GO
PRINT 'Permission granted successfully.';
GO

-- Check if the target database exists and drop it to ensure a clean slate
IF DB_ID('cricket_db') IS NOT NULL
BEGIN
    PRINT 'Database cricket_db exists - dropping it...';
    
    -- Set the database to single-user mode to disconnect all active users
    ALTER DATABASE cricket_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    
    -- Drop the database
    DROP DATABASE cricket_db;
    
    PRINT 'Database cricket_db dropped successfully.';
END
ELSE
BEGIN
    PRINT 'Database cricket_db does not exist, will proceed to create it.';
END
GO

-- Create a fresh database
PRINT 'Creating fresh database: cricket_db ...';
CREATE DATABASE cricket_db;
PRINT 'cricket_db database has been created successfully.';
GO

-- Switch to the newly created database context
USE cricket_db;
PRINT 'Now using the cricket_db database.';
GO

-- Create the players table
PRINT 'Creating players table...';
CREATE TABLE players(
    player_id VARCHAR(255) NULL,
    match_id INT NULL,
    player_name VARCHAR(255) NULL,
    team VARCHAR(255) NULL
);
GO
PRINT 'players table created successfully.';

-- Load data from the CSV file using BULK INSERT
PRINT 'Starting bulk loading to players table...';
BEGIN TRY
    BULK INSERT players
    FROM 'D:\cricket\code folder\csv output\players.csv'
    WITH (
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a', -- Using '0x0a' is a more robust way to specify the newline character
        FIRSTROW = 2,
        KEEPNULLS,
        TABLOCK,
        FORMAT = 'CSV',
        CODEPAGE = '65001' -- UTF-8 Codepage
    );
    
    -- Display a success message with the total number of records loaded
    DECLARE @RecordCount INT = (SELECT COUNT(*) FROM players);
    PRINT '=========================================';
    PRINT 'BULK LOAD COMPLETED SUCCESSFULLY!';
    PRINT '=========================================';
    PRINT 'Total records loaded: ' + CAST(@RecordCount AS VARCHAR(20));
    PRINT 'Database: cricket_db (Fresh)';
    PRINT 'Table: players (Fresh)';
    PRINT '=========================================';
    
END TRY
BEGIN CATCH
    -- Display detailed error information if the bulk insert fails
    PRINT '=========================================';
    PRINT 'ERROR: Bulk insert failed.';
    PRINT '=========================================';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(20));
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS VARCHAR(20));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS VARCHAR(20));
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(20));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT '=========================================';
END CATCH
GO

