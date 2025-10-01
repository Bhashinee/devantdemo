import ballerina/http;
import ballerina/io;

// Module-level map to track total records sent per table
map<int> recordsSentPerTable = {};

// Predefined epoch values to use as starting tokens
string[] epochTokens = ["eyJlZzEiOiAxNzQ4NjI4NDcwNDU1NzM3MjIwfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODQ4ODI1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODQ4ODc1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODM4ODc1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODMyODk1NTQxfQ==", "eyJlZzEiOiAxNzU4Nzc5MzM5ODMyODc1NTQxfQ=="];

// Module-level counter to track which epoch token to use next
int tokenIndex = 0;

// Helper function to filter JSON record based on selected fields
function filterRecord(json inputRecord, string[] selectedFields) returns json {
    if selectedFields.length() == 0 {
        return inputRecord;
    }
    
    map<json> filteredRecord = {};
    if inputRecord is map<json> {
        foreach string fieldName in selectedFields {
            string trimmedField = fieldName.trim();
            if inputRecord.hasKey(trimmedField) {
                json fieldValue = inputRecord.get(trimmedField);
                filteredRecord[trimmedField] = fieldValue;
            }
        }
    }
    return filteredRecord;
}

// Initialize HTTP service
service /consumer/v1/ams360 on new http:Listener(9080) {

    // Resource function to handle table requests
    resource function get 'table/[string tableName](
            string? 'limit = (),
            string? schema = (),
            string[] 'select = [],
            string? starting_token = ()
    ) returns ApiResponse|error {
        io:println("----------------select fields: ");
        io:println('select);

        // Process query parameters
        int pageLimit = 10; // default limit
        if 'limit is string {
            int|error limitResult = int:fromString('limit);
            if limitResult is int {
                pageLimit = limitResult;
            }
        }

        string tableSchema = schema ?: "public";
        
        // Use the select array directly - no need to parse as string
        string[] selectedFieldNames = 'select;
        
        // Get current record count for this specific table
        int currentTableRecordsSent = recordsSentPerTable[tableName] ?: 0;
        
        // Use the current records sent as the starting offset instead of token-based calculation
        int startOffset = currentTableRecordsSent;

        // Generate large mock data sets with 20080 records each
        json[] mockData = [];

        if tableName == "customers" {
            // Generate 20080 customer records with 30+ columns
            string[] firstNames = ["John", "Jane", "Bob", "Alice", "Charlie", "Diana", "Edward", "Fiona", "George", "Helen", 
                                 "Ian", "Julia", "Kevin", "Laura", "Michael", "Nancy", "Oliver", "Patricia", "Quinn", "Rachel", "Keyon"];
            string[] lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez",
                                "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin"];
            string[] cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia", "San Antonio", "San Diego",
                             "Dallas", "San Jose", "Austin", "Jacksonville", "Fort Worth", "Columbus", "Charlotte", "San Francisco",
                             "Indianapolis", "Seattle", "Denver", "Washington", "Boston", "El Paso", "Nashville", "Detroit", "Oklahoma City"];
            string[] states = ["NY", "CA", "IL", "TX", "AZ", "PA", "TX", "CA", "TX", "CA", "TX", "FL", "TX", "OH", "NC", "CA", "IN", "WA", "CO", "DC", "MA", "TX", "TN", "MI", "OK"];
            string[] occupations = ["Engineer", "Designer", "Manager", "Developer", "Analyst", "Consultant", "Director", "Specialist",
                                  "Coordinator", "Administrator", "Supervisor", "Technician", "Representative", "Assistant", "Executive"];
            string[] departments = ["Engineering", "Marketing", "Sales", "HR", "Finance", "Operations", "IT", "Customer Service", "Legal", "R&D"];
            string[] maritalStatus = ["Single", "Married", "Divorced", "Widowed"];
            string[] educationLevels = ["High School", "Bachelor's", "Master's", "PhD", "Associate"];
            string[] incomeRanges = ["25000-35000", "35000-50000", "50000-75000", "75000-100000", "100000-150000", "150000+"];
            string[] customerTypes = ["Premium", "Standard", "Basic", "VIP", "Corporate"];
            string[] communicationPrefs = ["Email", "Phone", "SMS", "Mail"];

            int i = 1;
            while i <= 20080 {
                string firstName = firstNames[(i - 1) % firstNames.length()];
                string lastName = lastNames[(i - 1) % lastNames.length()];
                string fullName = firstName + " " + lastName;
                string city = cities[(i - 1) % cities.length()];
                string state = states[(i - 1) % states.length()];
                string occupation = occupations[(i - 1) % occupations.length()];
                string department = departments[(i - 1) % departments.length()];
                string marital = maritalStatus[(i - 1) % maritalStatus.length()];
                string education = educationLevels[(i - 1) % educationLevels.length()];
                string incomeRange = incomeRanges[(i - 1) % incomeRanges.length()];
                string customerType = customerTypes[(i - 1) % customerTypes.length()];
                string commPref = communicationPrefs[(i - 1) % communicationPrefs.length()];
                
                int age = 22 + ((i - 1) % 43); // Ages between 22 and 64
                int zipCode = 10000 + ((i - 1) % 89999);
                decimal creditScore = 300.0d + <decimal>((i - 1) % 551); // Credit scores 300-850
                decimal annualIncome = 25000.0d + <decimal>((i - 1) % 175000); // Income 25k-200k
                boolean isActive = i % 10 != 0; // 90% active customers
                boolean hasInsurance = i % 3 == 0; // 33% have insurance
                int yearsWithCompany = (i - 1) % 25; // 0-24 years
                int dependents = (i - 1) % 6; // 0-5 dependents

                json customerRecord = {
                    "customer_id": i.toString(),
                    "first_name": firstName,
                    "last_name": lastName,
                    "full_name": fullName,
                    "email": firstName.toLowerAscii() + "." + lastName.toLowerAscii() + "@email.com",
                    "phone_primary": "(" + ((200 + (i % 800)).toString()) + ") " + ((100 + (i % 900)).toString()) + "-" + ((1000 + (i % 9000)).toString()),
                    "phone_secondary": "(" + ((300 + (i % 700)).toString()) + ") " + ((200 + (i % 800)).toString()) + "-" + ((2000 + (i % 8000)).toString()),
                    "address_line1": ((100 + (i % 9900)).toString()) + " " + firstNames[(i + 5) % firstNames.length()] + " Street",
                    "address_line2": i % 4 == 0 ? "Apt " + ((i % 50) + 1).toString() : (),
                    "city": city,
                    "state": state,
                    "zip_code": zipCode.toString(),
                    "country": "USA",
                    "age": age,
                    "date_of_birth": "19" + ((60 + (age - 22)).toString()) + "-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "gender": i % 2 == 0 ? "Male" : "Female",
                    "marital_status": marital,
                    "education_level": education,
                    "occupation": occupation,
                    "department": department,
                    "annual_income": annualIncome,
                    "income_range": incomeRange,
                    "credit_score": creditScore,
                    "customer_type": customerType,
                    "customer_since": "20" + ((10 + (yearsWithCompany / 10)).toString()) + "-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "years_with_company": yearsWithCompany,
                    "is_active": isActive,
                    "account_status": isActive ? "Active" : "Inactive",
                    "has_insurance": hasInsurance,
                    "number_of_dependents": dependents,
                    "communication_preference": commPref,
                    "last_contact_date": "2024-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "total_purchases": (i % 50) + 1,
                    "lifetime_value": <decimal>((i % 10000) + 500),
                    "preferred_contact_time": i % 3 == 0 ? "Morning" : (i % 3 == 1 ? "Afternoon" : "Evening"),
                    "social_security_last4": ((1000 + (i % 9000)).toString()),
                    "emergency_contact_name": lastNames[(i + 10) % lastNames.length()] + ", " + firstNames[(i + 15) % firstNames.length()],
                    "emergency_contact_phone": "(" + ((400 + (i % 600)).toString()) + ") " + ((300 + (i % 700)).toString()) + "-" + ((3000 + (i % 7000)).toString()),
                    "created_at": "2020-01-01T00:00:00Z",
                    "updated_at": "2024-01-01T00:00:00Z"
                };
                mockData.push(customerRecord);
                i = i + 1;
            }
        } else if tableName == "products" {
            // Generate 20080 product records with 30+ columns
            string[] productNames = ["Laptop", "Phone", "Tablet", "Monitor", "Keyboard", "Mouse", "Desk", "Chair", "Bookshelf", "Lamp",
                                   "Printer", "Scanner", "Camera", "Headphones", "Speaker", "Router", "Switch", "Cable", "Adapter", "Charger",
                                   "Battery", "Memory", "Storage", "Processor", "Motherboard", "Graphics Card", "Power Supply", "Case", "Fan", "Cooler"];
            string[] categories = ["Electronics", "Furniture", "Accessories", "Components", "Peripherals", "Storage", "Networking", "Audio", "Video", "Computing"];
            string[] brands = ["TechCorp", "InnovateTech", "FutureTech", "SmartDevices", "ProTech", "EliteElectronics", "NextGen", "PowerTech", "UltraTech", "MegaTech"];
            string[] suppliers = ["Global Supply Co", "Tech Distributors", "Premium Parts Inc", "Wholesale Electronics", "Direct Manufacturing"];
            string[] colors = ["Black", "White", "Silver", "Blue", "Red", "Green", "Gray", "Gold"];
            string[] conditions = ["New", "Refurbished", "Open Box", "Used - Like New"];
            string[] warranties = ["1 Year", "2 Years", "3 Years", "Lifetime", "90 Days"];
            string[] origins = ["USA", "China", "Japan", "Germany", "South Korea", "Taiwan"];

            int i = 1;
            while i <= 20080 {
                string productName = productNames[(i - 1) % productNames.length()];
                string category = categories[(i - 1) % categories.length()];
                string brand = brands[(i - 1) % brands.length()];
                string supplier = suppliers[(i - 1) % suppliers.length()];
                string color = colors[(i - 1) % colors.length()];
                string condition = conditions[(i - 1) % conditions.length()];
                string warranty = warranties[(i - 1) % warranties.length()];
                string origin = origins[(i - 1) % origins.length()];
                
                // Generate varied prices between $19.99 and $1999.99
                decimal basePrice = 19.99d;
                decimal priceMultiplier = <decimal>((i - 1) % 100 + 1);
                decimal price = basePrice + (priceMultiplier * 19.8d);
                decimal costPrice = price * 0.6d; // 60% of selling price
                decimal weight = 0.1d + <decimal>((i % 100) / 10); // 0.1 to 10.1 lbs
                int stockQuantity = (i % 1000) + 10; // 10-1009 units
                decimal rating = 1.0d + <decimal>((i % 40) / 10); // 1.0 to 5.0 rating
                int reviewCount = (i % 500) + 1; // 1-500 reviews

                json productRecord = {
                    "product_id": i.toString(),
                    "product_name": brand + " " + productName,
                    "brand": brand,
                    "category": category,
                    "subcategory": category + " - " + productName,
                    "sku": "SKU-" + i.toString().padStart(6, "0"),
                    "upc": "0" + ((12345678900 + i).toString()),
                    "model_number": brand.substring(0, 3).toUpperAscii() + "-" + i.toString(),
                    "price": price,
                    "cost_price": costPrice,
                    "msrp": price * 1.2d,
                    "discount_percentage": <decimal>((i % 50)),
                    "currency": "USD",
                    "description": "High-quality " + productName + " from " + brand + " with excellent features and reliability.",
                    "short_description": brand + " " + productName + " - Premium Quality",
                    "color": color,
                    "size": i % 3 == 0 ? "Small" : (i % 3 == 1 ? "Medium" : "Large"),
                    "weight": weight,
                    "dimensions": ((10 + (i % 20)).toString()) + "x" + ((8 + (i % 15)).toString()) + "x" + ((2 + (i % 8)).toString()) + " inches",
                    "condition": condition,
                    "warranty": warranty,
                    "supplier": supplier,
                    "supplier_id": "SUP-" + ((i % 100) + 1).toString().padStart(3, "0"),
                    "manufacturer": brand,
                    "country_of_origin": origin,
                    "stock_quantity": stockQuantity,
                    "reorder_level": stockQuantity / 10,
                    "max_stock_level": stockQuantity * 2,
                    "is_active": i % 20 != 0, // 95% active products
                    "is_featured": i % 10 == 0, // 10% featured products
                    "is_on_sale": i % 7 == 0, // ~14% on sale
                    "rating": rating,
                    "review_count": reviewCount,
                    "total_sold": (i % 10000) + 50,
                    "created_date": "2020-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "last_updated": "2024-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "launch_date": "2021-" + ((i % 12) + 1).toString().padStart(2, "0") + "-" + ((i % 28) + 1).toString().padStart(2, "0"),
                    "discontinue_date": i % 50 == 0 ? "2025-12-31" : (),
                    "tags": category + "," + brand + "," + color,
                    "barcode": "123456789" + i.toString().padStart(3, "0")
                };
                mockData.push(productRecord);
                i = i + 1;
            }
        } else {
            return error("Table not found");
        }

        int totalDataLength = mockData.length();
        
        io:println("Table: " + tableName + ", Total data generated: " + totalDataLength.toString() + ", Current records sent: " + currentTableRecordsSent.toString() + ", Start offset: " + startOffset.toString() + ", Select fields count: " + selectedFieldNames.length().toString());
        
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
            json originalRecord = mockData[i];
            // Apply field filtering based on select parameter
            json filteredRecord = filterRecord(originalRecord, selectedFieldNames);
            batchData.push(filteredRecord);
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
