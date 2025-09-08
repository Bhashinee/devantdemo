import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/io;

configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable string dbHost = ?;
configurable int dbPort = 3306;

// The `Student` record to load records from `student` table.
type Student record {|
    int id;
    string name;
    int age;
|};

service / on new http:Listener(9095) {
    private final mysql:Client db;

    function init() returns error? {
        // Initiate the mysql client at the start of the service. This will be used
        // throughout the lifetime of the service.
        self.db = check new (dbHost, dbUser, dbPassword, dbName, dbPort);
    }

    resource function get albums() returns Student[]|string|error {
        sql:ExecutionResult result = 
                check self.db->execute(`CREATE TABLE student (
                                           id INT AUTO_INCREMENT,
                                           age INT, 
                                           name VARCHAR(255), 
                                           PRIMARY KEY (id)
                                         )`);
        io:println("Table created successfully" + result.toString());
        sql:ExecutionResult insertResult = check self.db->execute(`INSERT INTO student(age, name)
                                                        VALUES (23, 'john')`);                                 
        io:println("Insert operation successful" + insertResult.toString());
        stream<Student, sql:Error?> studentStream = check self.db->query(`SELECT * FROM student`);

        // Collect the records from the stream to a list.
        return from Student student in studentStream
            select student;
    }
}
