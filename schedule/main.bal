import ballerina/log;
import ballerina/time;

public function main() returns error? {
    log:printInfo("=== Application Starting ===");
    log:printInfo("Timestamp: " + time:utcNow().toString());
    
    // Log different severity levels
    log:printDebug("Debug mode enabled - detailed execution information will be logged");
    log:printInfo("INFO: Application initialized successfully");
    log:printWarn("WARNING: This is a warning message example");
    
    // Simulate some processing with logs
    log:printInfo("Step 1: Loading configuration...");
    string config = "app.config";
    log:printDebug("Configuration file: " + config);
    
    log:printInfo("Step 2: Connecting to database...");
    boolean dbConnected = connectToDatabase();
    if dbConnected {
        log:printInfo("✓ Database connection established");
    } else {
        log:printError("✗ Database connection failed!");
        return error("Failed to connect to database");
    }
    
    log:printInfo("Step 3: Processing data...");
    int itemsProcessed = 0;
    foreach int i in 1...5 {
        log:printDebug("Processing item #" + i.toString());
        itemsProcessed += 1;
        log:printInfo("Progress: " + itemsProcessed.toString() + "/5 items completed");
    }
    
    log:printInfo("Step 4: Validating results...");
    error? validationResult = validateResults();
    if validationResult is error {
        log:printError("Validation failed: " + validationResult.message());
        log:printWarn("Attempting recovery procedure...");
        // Recovery logic here
    } else {
        log:printInfo("✓ Validation successful");
    }
    
    // Log with key-value pairs for structured logging
    log:printInfo("Processing summary", 
        itemsProcessed = itemsProcessed, 
        status = "completed",
        duration = "2.5s"
    );
    
    // Simulate error handling with logs
    error? processResult = riskyOperation();
    if processResult is error {
        log:printError("Error occurred during risky operation", 
            message = processResult.message()
        );
        log:printWarn("Continuing with degraded functionality");
    }
    
    // Final status
    log:printInfo("=== Application Completed Successfully ===");
    log:printDebug("Memory usage: 45MB");
    log:printDebug("Total execution time: 3.2 seconds");
    
    return;
}

function connectToDatabase() returns boolean {
    log:printDebug("Attempting database connection to localhost:5432");
    log:printDebug("Using connection pool with max 10 connections");
    // Simulate connection
    return true;
}

function validateResults() returns error? {
    log:printDebug("Running validation checks...");
    log:printDebug("Check 1: Data integrity - PASSED");
    log:printDebug("Check 2: Schema validation - PASSED");
    log:printDebug("Check 3: Business rules - PASSED");
    return;
}

function riskyOperation() returns error? {
    log:printDebug("Entering risky operation");
    log:printWarn("This operation may fail under certain conditions");
    
    log:printDebug("Risky operation completed without errors");
    return;
}