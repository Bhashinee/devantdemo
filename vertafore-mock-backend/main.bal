import ballerina/http;
import ballerina/io;

// Module-level map to track total records sent per table
map<int> recordsSentPerTable = {};

// Predefined epoch values to use as starting tokens
string[] epochTokens = ["eyJlZzEiOiAxNzQ4NjI4NDcwNDU1NzM3MjIwfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODQ4ODI1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODQ4ODc1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODM4ODc1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODMyODk1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODMyODc1NTQxfQ=="];

// Module-level counter to track which epoch token to use next
int tokenIndex = 0;

// Initialize HTTP service
service /consumer/v1/ams360 on new http:Listener(9080) {

    // Resource function to handle table requests
    resource function get 'table/[string tableName](
            string? 'limit = (),
            string? schema = (),
            string? 'select = (),
            string? starting_token = ()
    ) returns ApiResponse|error {

        // Process query parameters
        int pageLimit = 10; // default limit
        if 'limit is string {
            int|error limitResult = int:fromString('limit);
            if limitResult is int {
                pageLimit = limitResult;
            }
        }

        string tableSchema = schema ?: "public";
        string selectFields = 'select ?: "*";
        
        // Get current record count for this specific table
        int currentTableRecordsSent = recordsSentPerTable[tableName] ?: 0;
        
        // Use the current records sent as the starting offset instead of token-based calculation
        int startOffset = currentTableRecordsSent;

        // Generate large mock data sets with 20080 records each
        json[] mockData = [];

        if tableName == "customers" {
            // Generate 20080 customer records
            string[] firstNames = ["John", "Jane", "Bob", "Alice", "Charlie", "Diana", "Edward", "Fiona", "George", "Helen", 
                                 "Ian", "Julia", "Kevin", "Laura", "Michael", "Nancy", "Oliver", "Patricia", "Quinn", "Rachel", "Keyon"];
            string[] lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
                                "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin"];
            string[] cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego",
                             "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco",
                             "Indianapolis", "Seattle", "Denver", "Washington", "Boston", "El Paso", "Nashville", "Detroit", "Oklahoma City"];
            string[] occupations = ["Engineer", "Designer", "Manager", "Developer", "Analyst", "Consultant", "Director", "Specialist",
                                  "Coordinator", "Administrator", "Supervisor", "Technician", "Representative", "Assistant", "Executive"];

            int i = 1;
            while i <= 20080 {
                string firstName = firstNames[(i - 1) % firstNames.length()];
                string lastName = lastNames[(i - 1) % lastNames.length()];
                string fullName = firstName + " " + lastName;
                string city = cities[(i - 1) % cities.length()];
                string occupation = occupations[(i - 1) % occupations.length()];
                int age = 22 + ((i - 1) % 43); // Ages between 22 and 64

                json customerRecord = {
                    "id": i.toString(),
                    "name": fullName,
                    "age": age,
                    "city": city,
                    "occupation": occupation
                };
                mockData.push(customerRecord);
                i = i + 1;
            }
        } else if tableName == "products" {
            // Generate 20080 product records (same as customers)
            string[] productNames = ["Laptop", "Phone", "Tablet", "Monitor", "Keyboard", "Mouse", "Desk", "Chair", "Bookshelf", "Lamp",
                                   "Printer", "Scanner", "Camera", "Headphones", "Speaker", "Router", "Switch", "Cable", "Adapter", "Charger",
                                   "Battery", "Memory", "Storage", "Processor", "Motherboard", "Graphics Card", "Power Supply", "Case", "Fan", "Cooler"];
            string[] categories = ["Electronics", "Furniture", "Accessories", "Components", "Peripherals", "Storage", "Networking", "Audio", "Video", "Computing"];
            string[] brands = ["TechCorp", "InnovateTech", "FutureTech", "SmartDevices", "ProTech", "EliteElectronics", "NextGen", "PowerTech", "UltraTech", "MegaTech"];

            int i = 1;
            while i <= 20080 {
                string productName = productNames[(i - 1) % productNames.length()];
                string category = categories[(i - 1) % categories.length()];
                string brand = brands[(i - 1) % brands.length()];
                // Generate varied prices between $19.99 and $1999.99
                decimal basePrice = 19.99d;
                decimal priceMultiplier = <decimal>((i - 1) % 100 + 1);
                decimal price = basePrice + (priceMultiplier * 19.8d);

                json productRecord = {
                    "id": i.toString(),
                    "product_name": brand + " " + productName,
                    "price": price,
                    "category": category,
                    "brand": brand,
                    "sku": "SKU-" + i.toString().padStart(6, "0")
                };
                mockData.push(productRecord);
                i = i + 1;
            }
        } else {
            // Generate 20080 generic records for other table names
            // int i = 1;
            // while i <= 20080 {
            //     json genericRecord = {
            //         "id": i.toString(),
            //         "table_name": tableName,
            //         "message": "Generic data for " + tableName + " - Item " + i.toString(),
            //         "sequence": i,
            //         "status": i % 2 == 0 ? "active" : "inactive"
            //     };
            //     mockData.push(genericRecord);
            //     i = i + 1;
            // }
            return error("Table not found");
        }

        int totalDataLength = mockData.length();
        
        io:println("Table: " + tableName + ", Total data generated: " + totalDataLength.toString() + ", Current records sent: " + currentTableRecordsSent.toString() + ", Start offset: " + startOffset.toString());
        
        // Check if this specific table has already sent 20080 records, return empty content
        if currentTableRecordsSent >= 20080 {
            // Reset counter for this table for next cycle
            recordsSentPerTable[tableName] = 0;
            // Always provide a starting token - use first epoch token to restart cycle
            string restartToken = epochTokens[0];
            ApiResponse response = {
                content: [],
                starting_token: restartToken,
                recordCount: totalDataLength
            };
            io:println("Response for table " + tableName + " (20080 records already sent, returning empty content): ", response);
            return response;
        }
        
        // Check if start offset is beyond available data
        if startOffset >= totalDataLength {
            // Always provide a starting token - use next epoch token
            int currentTokenIndex = tokenIndex % epochTokens.length();
            string nextAvailableToken = epochTokens[currentTokenIndex];
            tokenIndex = tokenIndex + 1;
            ApiResponse response = {
                content: [],
                starting_token: nextAvailableToken,
                recordCount: totalDataLength
            };
            io:println("Response for table " + tableName + " (no more data): ", response);
            return response;
        }

        // Calculate the batch of data to return
        json[] batchData = [];
        int endOffset = startOffset + pageLimit;
        if endOffset > totalDataLength {
            endOffset = totalDataLength;
        }

        // Check if adding this batch would exceed 20080 total records sent for this table
        int recordsToSend = endOffset - startOffset;
        if currentTableRecordsSent + recordsToSend > 20080 {
            // Adjust to only send up to 20080 total records for this table
            recordsToSend = 20080 - currentTableRecordsSent;
            endOffset = startOffset + recordsToSend;
        }

        int i = startOffset;
        while i < endOffset {
            batchData.push(mockData[i]);
            i = i + 1;
        }

        // Update total records sent counter for this specific table
        recordsSentPerTable[tableName] = currentTableRecordsSent + batchData.length();

        // Always provide a starting token using predefined epoch values
        int currentTokenIndex = tokenIndex % epochTokens.length();
        string nextToken = epochTokens[currentTokenIndex];
        tokenIndex = tokenIndex + 1;

        // Create response
        ApiResponse response = {
            content: batchData,
            starting_token: nextToken,
            recordCount: totalDataLength
        };

        io:println("Response for table " + tableName + " (offset: " + startOffset.toString() + ", limit: " + pageLimit.toString() + ", total: " + totalDataLength.toString() + ", sent so far: " + recordsSentPerTable[tableName].toString() + ", batch size: " + batchData.length().toString() + "): ");

        return response;
    }
}
