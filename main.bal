import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable string dbHost = ?;
configurable int dbPort = 3306;

// The `Album` record to load records from `albums` table.
type Album record {|
    string id;
    string title;
    string artist;
    float price;
|};

service / on new http:Listener(9095) {
    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (dbHost, dbUser, dbPassword, dbName, dbPort);
    }

    resource function get albums() returns Album[]|error {
        // Execute simple query to retrieve all records from the `albums` table.
        stream<Album, sql:Error?> albumStream = self.db->query(`SELECT * FROM albums`);

        // Process the stream and convert results to Album[] or return error.
        return from Album album in albumStream
            select album;
    }
}
