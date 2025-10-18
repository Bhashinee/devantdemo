import ballerina/email;

public function main() returns error? {
    email:SmtpClient smtpClient = check new (
        host = smtpHost,
        clientConfig = {
            port: 25
        }
    );
    _ = check smtpClient->send(
        "bhashinee@wso2.com",
        "Results of Vertafore Data Processing",
        "devantintegrations@gmail.com",
        "emailBody"
    );
}
