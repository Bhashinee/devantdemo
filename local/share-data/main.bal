import ballerina/io;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string dbUser = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable string dbHost = ?;
configurable int dbPort = 3306;

final mysql:Client db = check new (dbHost, dbUser, dbPassword, dbName, dbPort);

// The `Album` record to load records from `albums` table.
type Album record {|
    string id;
    string title;
    string artist;
    float price;
|};

public function main() returns error? {
    sql:ExecutionResult result =
                check db->execute(`CREATE TABLE student (
                                           id INT AUTO_INCREMENT,
                                           age INT, 
                                           name VARCHAR(255), 
                                           PRIMARY KEY (id)
                                         )`);
    io:println("Table created succesfully" + result.toString());
    sql:ExecutionResult insertResult = check db->execute(`INSERT INTO student(age, name)
                                                        VALUES (23, 'john')`);
    io:println("Insert operation successful" + insertResult.toString());
}
