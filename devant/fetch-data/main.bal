import ballerina/http;

configurable string serviceurl = ?;
http:Client httpClient = check new (serviceurl);

service / on new http:Listener(9090) {

    resource function get greeting() returns string|error {
        string payload = check httpClient->/fetch();
        return payload;
    }
}
