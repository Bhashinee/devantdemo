import ballerina/http;

service / on new http:Listener(9090) {
    resource function get fetch() returns string {
        return "Data from local machine";
    }
}
