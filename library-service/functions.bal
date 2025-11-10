// Utility function to create success response
public function createSuccessResponse(string message, anydata data) returns ApiResponse {
    return {
        message: message,
        status: 200,
        data: data
    };
}

// Utility function to create error response
public function createErrorResponse(string message, int code) returns ErrorResponse {
    return {
        message: message,
        code: code
    };
}

// Function to validate user data
public function validateUser(User user) returns boolean {
    return user.name.trim() != "" && user.email.trim() != "";
}