import ballerina/http;

// HTTP service listener
listener http:Listener httpListener = new (9090);

// Main HTTP service
service /api on httpListener {
    
    // GET resource - returns a welcome message
    resource function get .() returns ApiResponse {
        return {
            message: "Welcome to the HTTP Service Library",
            status: 200,
            data: {
                version: "1.0.0",
                endpoints: ["/api", "/api/users", "/api/users/{id}"]
            }
        };
    }
    
    // GET resource for users list
    resource function get users() returns ApiResponse {
        User[] users = [
            {id: 1, name: "John Doe", email: "john@example.com"},
            {id: 2, name: "Jane Smith", email: "jane@example.com"}
        ];
        
        return {
            message: "Users retrieved successfully",
            status: 200,
            data: users
        };
    }
    
    // GET resource for specific user
    resource function get users/[int userId]() returns ApiResponse|ErrorResponse {
        if (userId <= 0) {
            return {
                message: "Invalid user ID",
                code: 400
            };
        }
        
        User user = {
            id: userId,
            name: "Sample User",
            email: "user@example.com"
        };
        
        return {
            message: "User retrieved successfully",
            status: 200,
            data: user
        };
    }
    
    // POST resource for creating users
    resource function post users(@http:Payload User newUser) returns ApiResponse|ErrorResponse {
        if (newUser.name.trim() == "" || newUser.email.trim() == "") {
            return {
                message: "Name and email are required",
                code: 400
            };
        }
        
        return {
            message: "User created successfully",
            status: 201,
            data: newUser
        };
    }
    
    // PUT resource for updating users
    resource function put users/[int userId](@http:Payload User updatedUser) returns ApiResponse|ErrorResponse {
        if (userId <= 0) {
            return {
                message: "Invalid user ID",
                code: 400
            };
        }
        
        if (updatedUser.name.trim() == "" || updatedUser.email.trim() == "") {
            return {
                message: "Name and email are required",
                code: 400
            };
        }
        
        User user = {
            id: userId,
            name: updatedUser.name,
            email: updatedUser.email
        };
        
        return {
            message: "User updated successfully",
            status: 200,
            data: user
        };
    }
    
    // DELETE resource for removing users
    resource function delete users/[int userId]() returns ApiResponse|ErrorResponse {
        if (userId <= 0) {
            return {
                message: "Invalid user ID",
                code: 400
            };
        }
        
        return {
            message: "User deleted successfully",
            status: 200,
            data: {id: userId}
        };
    }
    
    // Health check endpoint
    resource function get health() returns ApiResponse {
        return {
            message: "Service is healthy",
            status: 200,
            data: {
                timestamp: "2024-01-01T00:00:00Z",
                uptime: "running"
            }
        };
    }
}

service /api2 on httpListener {
    resource function get health() returns ApiResponse {
        return {
            message: "Service is healthy",
            status: 200,
            data: {
                timestamp: "2024-01-01T00:00:00Z",
                uptime: "running"
            }
        };
    }
}
