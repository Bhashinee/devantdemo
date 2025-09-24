// Record type to represent person data
public type Person record {
    string name;
    int age;
    string city;
    string occupation;
};

// Record type for API response with updated structure
public type ApiResponse record {
    json[] content;
    string? starting_token;
    int recordCount;
};

// Record type for table data
public type TableData record {
    string id;
    string name;
    json attributes;
};
