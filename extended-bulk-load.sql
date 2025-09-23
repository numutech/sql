-- ========================================================================
--  Complete Cricket DB Setup & All-Files Bulk Loading Script (Corrected)
--  Description: Fixes data type mismatches to ensure all 8 CSV files
--               are loaded correctly into the database.
-- ========================================================================

-- Switch to the master database to perform server-level operations
USE master;
GO

-- Grant the necessary permission to your Windows login.
PRINT 'Granting ADMINISTER BULK OPERATIONS permission to [MSI\numutech]...';
GRANT ADMINISTER BULK OPERATIONS TO [MSI\numutech];
GO
PRINT 'Permission granted successfully.';
GO

-- Check if the target database exists and drop it to ensure a clean slate
IF DB_ID('cricket_db') IS NOT NULL
BEGIN
    PRINT 'Database cricket_db exists - dropping it...';
    ALTER DATABASE cricket_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
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
GO
PRINT 'Now using the cricket_db database.';
GO

-- ========================================================================
-- TABLE CREATION SECTION (WITH CORRECTIONS)
-- ========================================================================

PRINT 'Creating all necessary tables...';

CREATE TABLE players (
    player_id VARCHAR(100),
    match_id SMALLINT,
    player_name VARCHAR(100),
    team VARCHAR(100)
);

CREATE TABLE match_details (
    match_id SMALLINT,
    event_name VARCHAR(255),
    match_number TINYINT,
    match_type VARCHAR(50),
    venue VARCHAR(255),
    city VARCHAR(100),
    start_date DATE,
    end_date DATE,
    season VARCHAR(50),
    gender VARCHAR(20),
    balls_per_over TINYINT,
    team_type VARCHAR(50),
    toss_winner VARCHAR(100),
    toss_decision VARCHAR(20),
    outcome_winner VARCHAR(100),
    outcome_by_runs DECIMAL(7, 1),
    -- FINAL CORRECTION: Changed from TINYINT to handle decimal values like '7.0'
    outcome_by_wickets DECIMAL(3, 1),
    player_of_match VARCHAR(100)
);

CREATE TABLE deliveries (
    delivery_id INT,
    match_id SMALLINT,
    innings_number TINYINT,
    over_number TINYINT,
    ball_number TINYINT,
    batting_team VARCHAR(100),
    batter VARCHAR(100),
    non_striker VARCHAR(100),
    bowler VARCHAR(100),
    runs_batter TINYINT,
    runs_extras TINYINT,
    runs_total TINYINT
);

CREATE TABLE innings (
    match_id SMALLINT,
    innings_number TINYINT,
    batting_team VARCHAR(100),
    declared VARCHAR(100),
    forfeited VARCHAR(100),
    series_name VARCHAR(255)
);

CREATE TABLE wickets (
    delivery_id INT,
    match_id SMALLINT,
    innings_number TINYINT,
    player_out VARCHAR(100),
    kind VARCHAR(100)
);

CREATE TABLE fielders (
    delivery_id INT,
    match_id int,
    fielder_name VARCHAR(100)
);

CREATE TABLE teams (
    match_id SMALLINT,
    teamA_players VARCHAR(MAX),
    teamB_players VARCHAR(MAX)
);

CREATE TABLE officials (
    match_id SMALLINT,
    umpires VARCHAR(255),
    referee VARCHAR(100),
    tv_umpire VARCHAR(100),
    reserve_umpire VARCHAR(100)
);
GO
PRINT 'All 8 tables created successfully.';
GO

-- ========================================================================
-- DATA LOADING SECTION
-- ========================================================================

CREATE PROCEDURE dbo.LoadCsvFile
    @TableName NVARCHAR(128),
    @CsvFileName NVARCHAR(255)
AS
BEGIN
    DECLARE @FilePath NVARCHAR(500) = 'C:\Users\numutech\csv output\' + @CsvFileName;
    DECLARE @SqlCmd NVARCHAR(MAX);

    SET @SqlCmd = '
        BEGIN TRY
            BULK INSERT ' + QUOTENAME(@TableName) + '
            FROM ''' + @FilePath + '''
            WITH (
                FIELDTERMINATOR = ''|'',
                ROWTERMINATOR = ''0x0a'',
                FIRSTROW = 2,
                KEEPNULLS,
                TABLOCK,
                FORMAT = ''CSV'',
                CODEPAGE = ''65001''
            );

            DECLARE @RowCount INT;
            DECLARE @CountQuery NVARCHAR(200) = N''SELECT @cnt = COUNT(*) FROM ' + QUOTENAME(@TableName) + ''';
            EXEC sp_executesql @CountQuery, N''@cnt INT OUTPUT'', @cnt = @RowCount OUTPUT;
            PRINT ''-> SUCCESS: Loaded '' + CAST(@RowCount AS VARCHAR(20)) + '' records into ' + QUOTENAME(@TableName) + '.'';
        END TRY
        BEGIN CATCH
            PRINT ''-> ERROR on ' + QUOTENAME(@TableName) + ': '' + ERROR_MESSAGE();
        END CATCH';

    PRINT '---------------------------------------------------';
    PRINT 'Starting bulk load for: ' + QUOTENAME(@TableName) + ' from ' + @CsvFileName;
    EXEC sp_executesql @SqlCmd;
END;
GO

-- Execute the loading procedure for each CSV file
EXEC dbo.LoadCsvFile 'players', 'players.csv';
EXEC dbo.LoadCsvFile 'match_details', 'matches.csv';
EXEC dbo.LoadCsvFile 'deliveries', 'deliveries.csv';
EXEC dbo.LoadCsvFile 'innings', 'innings.csv';
EXEC dbo.LoadCsvFile 'wickets', 'wickets.csv';
EXEC dbo.LoadCsvFile 'fielders', 'fielders.csv'; -- Using the uploaded filename 'filders.csv'
EXEC dbo.LoadCsvFile 'teams', 'teams.csv';
EXEC dbo.LoadCsvFile 'officials', 'officials.csv';
GO

-- ========================================================================
-- FINAL SUMMARY SECTION
-- ========================================================================

PRINT '';
PRINT '=============================================';
PRINT '      BULK LOADING PROCESS COMPLETED       ';
PRINT '=============================================';

DECLARE @TotalRecords BIGINT = 0;
DECLARE @TableRowCounts TABLE (TableName VARCHAR(128), RecordCount INT);

INSERT INTO @TableRowCounts
SELECT 'players', COUNT(*) FROM players UNION ALL
SELECT 'match_details', COUNT(*) FROM match_details UNION ALL
SELECT 'deliveries', COUNT(*) FROM deliveries UNION ALL
SELECT 'innings', COUNT(*) FROM innings UNION ALL
SELECT 'wickets', COUNT(*) FROM wickets UNION ALL
SELECT 'fielders', COUNT(*) FROM fielders UNION ALL
SELECT 'teams', COUNT(*) FROM teams UNION ALL
SELECT 'officials', COUNT(*) FROM officials;

SELECT @TotalRecords = SUM(RecordCount) FROM @TableRowCounts;

PRINT 'Database: cricket_db';
PRINT 'Table Summary:';

SELECT '- ' + TableName + REPLICATE(' ', 15 - LEN(TableName)) + ': ' + CAST(RecordCount AS VARCHAR(20)) + ' records'
FROM @TableRowCounts;

PRINT '---------------------------------------------';
PRINT 'Total records loaded: ' + CAST(@TotalRecords AS VARCHAR(20));
PRINT '=============================================';
GO

PRINT 'Script execution finished successfully!';
GO
