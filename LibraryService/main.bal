import ballerina/http;
import ballerina/io as _;
import ballerina/time as _;
import ballerina/log as _;
import ballerina/sql as _;
import ballerina/uuid as _;
import ballerina/mime as _;
import ballerina/file as _;
import ballerina/cache as _;
import ballerina/crypto as _;
import ballerina/regex as _;
import ballerina/lang.'int as _;
import ballerina/lang.'string as _;
import ballerina/lang.'array as _;
import ballerina/lang.'map as _;
import ballerina/lang.'value as _;
import ballerina/lang.'decimal as _;
import ballerina/lang.'float as _;
import ballerina/lang.'boolean as _;
import ballerina/jwt as _;
import ballerina/oauth2 as _;
import ballerina/url as _;
import ballerina/email as _;
import ballerina/task as _;
import ballerina/websocket as _;
import ballerina/grpc as _;
import ballerina/graphql as _;
import ballerina/tcp as _;
import ballerina/udp as _;
import ballerina/xmldata as _;
import ballerina/data.csv as _;
import ballerina/data.jsondata as _;
import ballerinax/mysql as _;
import ballerinax/postgresql as _;
import ballerinax/kafka as _;
import ballerinax/redis as _;
import ballerinax/aws.dynamodb as _;
import ballerinax/aws.dynamodbstreams as _;
import ballerinax/aws.marketplace.mpe as _;
import ballerinax/aws.marketplace.mpm as _;
import ballerinax/aws.redshift as _;
import ballerinax/aws.redshift.driver as _;
import ballerinax/aws.redshiftdata as _;
import ballerinax/aws.s3 as _;
import ballerinax/aws.secretmanager as _;
import ballerinax/aws.ses as _;
import ballerinax/aws.simpledb as _;
import ballerinax/aws.sns as _;
import ballerinax/aws.sqs as _;
import ballerinax/azure.functions as _;

// Record definitions
type Book record {|
    string bookId;
    string title;
    string author;
    string isbn;
    boolean available;
|};

type Member record {|
    string memberId;
    string name;
    string email;
    string phoneNumber;
|};

type BorrowRecord record {|
    string borrowId;
    string bookId;
    string memberId;
    string borrowDate;
    string? returnDate;
|};

type BookInput record {|
    string title;
    string author;
    string isbn;
|};

type MemberInput record {|
    string name;
    string email;
    string phoneNumber;
|};

type BorrowInput record {|
    string bookId;
    string memberId;
|};

type ErrorResponse record {|
    string message;
|};

// In-memory storage
map<Book> booksTable = {};
map<Member> membersTable = {};
map<BorrowRecord> borrowRecordsTable = {};

int bookCounter = 1;
int memberCounter = 1;
int borrowCounter = 1;

// HTTP listener
listener http:Listener httpListener = check new (8080);

// Library service
service /library on httpListener {

    // Book Management APIs

    // Create a new book
    resource function post books(@http:Payload BookInput bookInput) returns Book|error {
        string newBookId = string `B${bookCounter}`;
        bookCounter += 1;

        Book newBook = {
            bookId: newBookId,
            title: bookInput.title,
            author: bookInput.author,
            isbn: bookInput.isbn,
            available: true
        };

        booksTable[newBookId] = newBook;
        return newBook;
    }

    // Get all books
    resource function get books() returns Book[] {
        return booksTable.toArray();
    }

    // Get a specific book by ID
    resource function get books/[string bookId]() returns Book|ErrorResponse {
        Book? book = booksTable[bookId];
        if book is Book {
            return book;
        }
        return {message: string `Book with ID ${bookId} not found`};
    }

    // Update a book
    resource function put books/[string bookId](@http:Payload BookInput bookInput) returns Book|ErrorResponse {
        Book? existingBook = booksTable[bookId];
        if existingBook is () {
            return {message: string `Book with ID ${bookId} not found`};
        }

        Book updatedBook = {
            bookId: bookId,
            title: bookInput.title,
            author: bookInput.author,
            isbn: bookInput.isbn,
            available: existingBook.available
        };

        booksTable[bookId] = updatedBook;
        return updatedBook;
    }

    // Delete a book
    resource function delete books/[string bookId]() returns http:Ok|ErrorResponse {
        Book? book = booksTable[bookId];
        if book is () {
            return {message: string `Book with ID ${bookId} not found`};
        }

        Book removedBook = booksTable.remove(bookId);
        return http:OK;
    }

    // Member Management APIs

    // Create a new member
    resource function post members(@http:Payload MemberInput memberInput) returns Member|error {
        string newMemberId = string `M${memberCounter}`;
        memberCounter += 1;

        Member newMember = {
            memberId: newMemberId,
            name: memberInput.name,
            email: memberInput.email,
            phoneNumber: memberInput.phoneNumber
        };

        membersTable[newMemberId] = newMember;
        return newMember;
    }

    // Get all members
    resource function get members() returns Member[] {
        return membersTable.toArray();
    }

    // Get a specific member by ID
    resource function get members/[string memberId]() returns Member|ErrorResponse {
        Member? member = membersTable[memberId];
        if member is Member {
            return member;
        }
        return {message: string `Member with ID ${memberId} not found`};
    }

    // Update a member
    resource function put members/[string memberId](@http:Payload MemberInput memberInput) returns Member|ErrorResponse {
        Member? existingMember = membersTable[memberId];
        if existingMember is () {
            return {message: string `Member with ID ${memberId} not found`};
        }

        Member updatedMember = {
            memberId: memberId,
            name: memberInput.name,
            email: memberInput.email,
            phoneNumber: memberInput.phoneNumber
        };

        membersTable[memberId] = updatedMember;
        return updatedMember;
    }

    // Delete a member
    resource function delete members/[string memberId]() returns http:Ok|ErrorResponse {
        Member? member = membersTable[memberId];
        if member is () {
            return {message: string `Member with ID ${memberId} not found`};
        }

        Member removedMember = membersTable.remove(memberId);
        return http:OK;
    }

    // Borrowing Operations APIs

    // Borrow a book
    resource function post borrow(@http:Payload BorrowInput borrowInput) returns BorrowRecord|ErrorResponse {
        Book? book = booksTable[borrowInput.bookId];
        if book is () {
            return {message: string `Book with ID ${borrowInput.bookId} not found`};
        }

        Member? member = membersTable[borrowInput.memberId];
        if member is () {
            return {message: string `Member with ID ${borrowInput.memberId} not found`};
        }

        if !book.available {
            return {message: string `Book with ID ${borrowInput.bookId} is not available`};
        }

        string newBorrowId = string `BR${borrowCounter}`;
        borrowCounter += 1;

        BorrowRecord newBorrowRecord = {
            borrowId: newBorrowId,
            bookId: borrowInput.bookId,
            memberId: borrowInput.memberId,
            borrowDate: "2024-01-15",
            returnDate: ()
        };

        borrowRecordsTable[newBorrowId] = newBorrowRecord;

        Book updatedBook = {
            bookId: book.bookId,
            title: book.title,
            author: book.author,
            isbn: book.isbn,
            available: false
        };
        booksTable[borrowInput.bookId] = updatedBook;

        return newBorrowRecord;
    }

    // Return a book
    resource function post 'return/[string borrowId]() returns BorrowRecord|ErrorResponse {
        BorrowRecord? borrowRecord = borrowRecordsTable[borrowId];
        if borrowRecord is () {
            return {message: string `Borrow record with ID ${borrowId} not found`};
        }

        if borrowRecord.returnDate is string {
            return {message: string `Book has already been returned`};
        }

        BorrowRecord updatedBorrowRecord = {
            borrowId: borrowRecord.borrowId,
            bookId: borrowRecord.bookId,
            memberId: borrowRecord.memberId,
            borrowDate: borrowRecord.borrowDate,
            returnDate: "2024-01-20"
        };
        borrowRecordsTable[borrowId] = updatedBorrowRecord;

        Book? book = booksTable[borrowRecord.bookId];
        if book is Book {
            Book updatedBook = {
                bookId: book.bookId,
                title: book.title,
                author: book.author,
                isbn: book.isbn,
                available: true
            };
            booksTable[borrowRecord.bookId] = updatedBook;
        }

        return updatedBorrowRecord;
    }

    // Get all borrow records
    resource function get borrow() returns BorrowRecord[] {
        return borrowRecordsTable.toArray();
    }

    // Get borrow records by member ID
    resource function get borrow/member/[string memberId]() returns BorrowRecord[] {
        BorrowRecord[] memberBorrowRecords = [];
        foreach BorrowRecord borrowRecord in borrowRecordsTable {
            if borrowRecord.memberId == memberId {
                memberBorrowRecords.push(borrowRecord);
            }
        }
        return memberBorrowRecords;
    }

    // Get currently borrowed books (not returned)
    resource function get borrow/active() returns BorrowRecord[] {
        BorrowRecord[] activeBorrowRecords = [];
        foreach BorrowRecord borrowRecord in borrowRecordsTable {
            if borrowRecord.returnDate is () {
                activeBorrowRecords.push(borrowRecord);
            }
        }
        return activeBorrowRecords;
    }
}
