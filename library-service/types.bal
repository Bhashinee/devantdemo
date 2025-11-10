// Response record for API responses
public type ApiResponse record {|
    string message;
    int status;
    anydata data?;
|};

// User record for demonstration
public type User record {|
    int id;
    string name;
    string email;
|};

// Error response record
public type ErrorResponse record {|
    string message;
    int code;
|};