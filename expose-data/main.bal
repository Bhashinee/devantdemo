import ballerina/http;

service / on new http:Listener(8090) {
    resource function get greeting() returns string {
        return "Data from expose-data service";
    }
}
