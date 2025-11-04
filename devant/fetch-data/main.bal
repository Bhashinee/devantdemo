import ballerina/email;

public function main() returns error? {
    email:SmtpClient smtpClient = check new (
        host = "mxa-001d6001.gslb.pphosted.com",
        clientConfig = {
            port: 25,
            security: email:START_TLS_NEVER
        }
    );
    _ = check smtpClient->send(
        "manoj.gunawardena@provident.bank",
        "Results of Vertafore Data Processing",
        "devantintegrations@gmail.com",
        "emailBody"
    );
}
