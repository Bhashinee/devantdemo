import ballerina/graphql;

// A record type representing a simple greeting object.
public type Greeting record {|
    readonly string content;
|};

// Service attached to a GraphQL listener on port 9090.
service /graphql on new graphql:Listener(9090) {

    // A resource method with the 'get' accessor represents a field in the 
    // GraphQL Query type. The name of the method (greeting) becomes the field name.
    resource function get greeting() returns Greeting {
        return {
            content: "Hello, world!"
        };
    }
}
