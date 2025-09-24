import ballerina/http;
import ballerina/io;

// HTTP service configuration
configurable int servicePort = 8080;

// Initialize HTTP service
service /consumer/v1/ams360 on new http:Listener(servicePort) {

    // Resource function to handle table requests
    resource function get 'table/[string tableName](
            string? 'limit = (),
            string? schema = (),
            string? 'select = (),
            string? starting_token = ()
    ) returns ApiResponse|http:InternalServerError {

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
        
        // Parse starting token to get offset
        int startOffset = 0;
        if starting_token is string {
            int|error tokenResult = int:fromString(starting_token);
            if tokenResult is int {
                startOffset = tokenResult;
            }
        }

        // Generate large mock data sets with 4000 records each
        json[] mockData = [];

        if tableName == "customers" {
            // Generate 4000 customer records
            string[] firstNames = ["John", "Jane", "Bob", "Alice", "Charlie", "Diana", "Edward", "Fiona", "George", "Helen", 
                                 "Ian", "Julia", "Kevin", "Laura", "Michael", "Nancy", "Oliver", "Patricia", "Quinn", "Rachel"];
            string[] lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
                                "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin"];
            string[] cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego",
                             "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco",
                             "Indianapolis", "Seattle", "Denver", "Washington", "Boston", "El Paso", "Nashville", "Detroit", "Oklahoma City"];
            string[] occupations = ["Engineer", "Designer", "Manager", "Developer", "Analyst", "Consultant", "Director", "Specialist",
                                  "Coordinator", "Administrator", "Supervisor", "Technician", "Representative", "Assistant", "Executive"];

            int i = 1;
            while i <= 4000 {
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
            // Generate 4000 product records
            string[] productNames = ["Laptop", "Phone", "Tablet", "Monitor", "Keyboard", "Mouse", "Desk", "Chair", "Bookshelf", "Lamp",
                                   "Printer", "Scanner", "Camera", "Headphones", "Speaker", "Router", "Switch", "Cable", "Adapter", "Charger",
                                   "Battery", "Memory", "Storage", "Processor", "Motherboard", "Graphics Card", "Power Supply", "Case", "Fan", "Cooler"];
            string[] categories = ["Electronics", "Furniture", "Accessories", "Components", "Peripherals", "Storage", "Networking", "Audio", "Video", "Computing"];
            string[] brands = ["TechCorp", "InnovateTech", "FutureTech", "SmartDevices", "ProTech", "EliteElectronics", "NextGen", "PowerTech", "UltraTech", "MegaTech"];

            int i = 1;
            while i <= 4000 {
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
            // Generate 4000 generic records for other table names
            int i = 1;
            while i <= 4000 {
                json genericRecord = {
                    "id": i.toString(),
                    "table_name": tableName,
                    "message": "Generic data for " + tableName + " - Item " + i.toString(),
                    "sequence": i,
                    "status": i % 2 == 0 ? "active" : "inactive"
                };
                mockData.push(genericRecord);
                i = i + 1;
            }
        }

        int totalDataLength = mockData.length();
        
        // Check if start offset is beyond available data
        if startOffset >= totalDataLength {
            ApiResponse response = {
                content: [],
                starting_token: (),
                recordCount: totalDataLength
            };
            io:println("Response (no more data): ", response);
            return response;
        }

        // Calculate the batch of data to return
        json[] batchData = [];
        int endOffset = startOffset + pageLimit;
        if endOffset > totalDataLength {
            endOffset = totalDataLength;
        }

        int i = startOffset;
        while i < endOffset {
            batchData.push(mockData[i]);
            i = i + 1;
        }

        // Determine next starting token
        string? nextToken = ();
        if endOffset < totalDataLength {
            nextToken = endOffset.toString();
        }

        // Create response
        ApiResponse response = {
            content: batchData,
            starting_token: nextToken,
            recordCount: totalDataLength
        };

        io:println("Response (offset: " + startOffset.toString() + ", limit: " + pageLimit.toString() + ", total: " + totalDataLength.toString() + "): ");

        return response;
    }
}
