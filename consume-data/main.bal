import ballerina/http;

http:Client exposeDataClient = check new ("http://localhost:8090");

service / on new http:Listener(9090) {
    
    resource function get data() returns string|error {
        // Call the expose-data endpoint
        string response = check exposeDataClient->get("/greeting");
        return response;
    }
}