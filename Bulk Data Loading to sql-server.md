# SQL Server Database Management and Bulk Data Loading: Complete Beginner's Guide

## Introduction

This SQL script demonstrates a complete database lifecycle management process - from dropping an existing database to creating a fresh one and loading data from a CSV file. This is a common pattern used in data analysis projects when you need to reset your database environment with clean data.

## Code Breakdown and Explanation

### 1. Database Context Switching

```sql
USE master;
GO
```

**What it does:** Switches the current database context to the `master` database.

**Why it's important:** You cannot drop a database while you're currently using it. The `master` database is SQL Server's system database that's always available, making it a safe place to execute administrative commands.

**Example:** Think of it like closing a file before deleting it - you need to step out of the database before you can drop it.

### 2. Conditional Database Dropping

```sql
IF DB_ID('LoanAnalysisDB') IS NOT NULL
BEGIN
    PRINT 'Database LoanAnalysisDB exists - dropping it...'
    ALTER DATABASE LoanAnalysisDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LoanAnalysisDB;
    PRINT 'Database LoanAnalysisDB dropped successfully'
END
ELSE
BEGIN
    PRINT 'Database LoanAnalysisDB does not exist'
END
```

**What it does:**

- `DB_ID('LoanAnalysisDB')` checks if the database exists
- If it exists, it safely drops the database
- If it doesn't exist, it prints a message

**Key Components:**

- **`DB_ID()`**: Returns the database ID if it exists, NULL if it doesn't
- **`ALTER DATABASE ... SET SINGLE_USER`**: Disconnects all users from the database
- **`WITH ROLLBACK IMMEDIATE`**: Forces immediate disconnection of all users
- **`DROP DATABASE`**: Permanently deletes the database

**Example Scenario:**

```sql
-- If database exists: DB_ID returns 5 (or some number)
-- If database doesn't exist: DB_ID returns NULL
```


### 3. Fresh Database Creation

```sql
CREATE DATABASE LoanAnalysisDB;
GO

USE LoanAnalysisDB;
GO
```

**What it does:** Creates a new, empty database and switches to it.

**Best Practice:** Always use `GO` after database operations to ensure they complete before the next command executes.

### 4. Table Structure Definition

```sql
CREATE TABLE LoanData (
    LoanID VARCHAR(15) NOT NULL,
    Age TINYINT,
    Income INT,
    LoanAmount INT,
    CreditScore SMALLINT,
    MonthsEmployed TINYINT,
    NumCreditLines TINYINT,
    InterestRate DECIMAL(5,2),
    LoanTerm TINYINT,
    DTIRatio DECIMAL(3,2),
    Education VARCHAR(15),
    EmploymentType VARCHAR(15),
    MaritalStatus VARCHAR(10),
    HasMortgage VARCHAR(5),
    HasDependents VARCHAR(5),
    LoanPurpose VARCHAR(15),
    HasCoSigner VARCHAR(5),
    DefaultStatus BIT,
    LoanDate DATE,
    CONSTRAINT PK_LoanData PRIMARY KEY (LoanID)
);
```

**Data Type Explanations:**


| Data Type | Description | Example Values | Storage Size |
| :-- | :-- | :-- | :-- |
| `VARCHAR(15)` | Variable-length string, max 15 characters | "LOAN001", "Education" | 1-15 bytes |
| `TINYINT` | Small integer (0-255) | 25, 120, 8 | 1 byte |
| `INT` | Standard integer | 50000, 125000 | 4 bytes |
| `SMALLINT` | Small integer (-32,768 to 32,767) | 650, 750 | 2 bytes |
| `DECIMAL(5,2)` | Decimal with 5 total digits, 2 after decimal | 12.50, 125.75 | 5 bytes |
| `BIT` | Boolean (0 or 1) | 0 (False), 1 (True) | 1 bit |
| `DATE` | Date only | '2025-09-21' | 3 bytes |

**Primary Key Constraint:**

```sql
CONSTRAINT PK_LoanData PRIMARY KEY (LoanID)
```

- Ensures each `LoanID` is unique
- Automatically creates an index for fast lookups
- Prevents NULL values in the `LoanID` column


### 5. Bulk Data Loading with Error Handling

```sql
BEGIN TRY
    BULK INSERT LoanData
    FROM 'C:\Users\numutech\Dataset\Loan_default.csv'
    WITH (
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        FIRSTROW = 2,
        KEEPNULLS,
        TABLOCK,
        FORMAT = 'CSV',
        CODEPAGE = '65001'
    );
END TRY
BEGIN CATCH
    -- Error handling code
END CATCH
```

**BULK INSERT Parameters Explained:**


| Parameter | Purpose | Example |
| :-- | :-- | :-- |
| `FIELDTERMINATOR = ','` | Defines column separator | Comma-separated values |
| `ROWTERMINATOR = '\n'` | Defines row separator | New line character |
| `FIRSTROW = 2` | Skips header row | Starts importing from row 2 |
| `KEEPNULLS` | Preserves empty fields as NULL | Empty cells become NULL |
| `TABLOCK` | Uses table-level locking for performance | Faster bulk operations |
| `FORMAT = 'CSV'` | Specifies CSV format handling | Handles quoted fields properly |
| `CODEPAGE = '65001'` | UTF-8 encoding | Supports international characters |

### 6. Success Reporting

```sql
DECLARE @RecordCount INT = (SELECT COUNT(*) FROM LoanData);
PRINT 'Total records loaded: ' + CAST(@RecordCount AS VARCHAR(10));
```

**What it does:**

- Counts the total records in the newly loaded table
- Converts the number to a string for display
- Provides confirmation of successful load


## Sample CSV Data Structure

Your `Loan_default.csv` file should look like this:

```csv
LoanID,Age,Income,LoanAmount,CreditScore,MonthsEmployed,NumCreditLines,InterestRate,LoanTerm,DTIRatio,Education,EmploymentType,MaritalStatus,HasMortgage,HasDependents,LoanPurpose,HasCoSigner,DefaultStatus,LoanDate
LOAN001,35,75000,25000,720,48,5,5.25,36,0.33,Bachelor,Full-time,Married,Yes,Yes,Home,No,0,2023-01-15
LOAN002,28,45000,15000,650,24,3,7.50,24,0.40,High School,Part-time,Single,No,No,Auto,Yes,1,2023-02-20
```


## Error Handling Features

The script includes comprehensive error handling:

```sql
BEGIN CATCH
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
END CATCH
```

**Common Errors and Solutions:**

1. **File Path Issues**: Ensure the file path `C:\Users\numutech\Dataset\Loan_default.csv` exists
2. **Permission Issues**: SQL Server service account needs read access to the file
3. **Data Type Mismatches**: Ensure CSV data matches the table column types
4. **Encoding Issues**: Use `CODEPAGE = '65001'` for UTF-8 files

## Best Practices Demonstrated

1. **Always use transactions** for bulk operations
2. **Check for existence** before dropping objects
3. **Use appropriate data types** to optimize storage
4. **Include error handling** for robust scripts
5. **Provide feedback** on operation success/failure
6. **Use GO statements** to batch commands properly

## Practical Applications

This pattern is commonly used for:

- **Data Analysis Projects**: Loading fresh datasets for analysis
- **ETL Processes**: Extract, Transform, Load operations
- **Development Environments**: Resetting databases with clean data
- **Testing Scenarios**: Creating reproducible test environments
- **Data Migration**: Moving data between systems


## Next Steps for Learning

After understanding this script, you should explore:

1. **Basic SELECT queries** to analyze the loaded data
2. **Data validation techniques** to check data quality
3. **Indexing strategies** for better performance
4. **Backup and restore operations** for data protection
5. **Advanced bulk loading options** like OPENROWSET

This script provides a solid foundation for understanding database lifecycle management and bulk data operations in SQL Server, essential skills for any data analyst working with SQL databases.

