import ballerina/http;

listener http:Listener ep0 = new (9090);

service / on ep0 {
    resource function get books() returns json | http:NotFound {
        json booksList = [
            { "id": "1", "title": "1984", "author": "George Orwell" },
            { "id": "2", "title": "To Kill a Mockingbird", "author": "Harper Lee" },
            { "id": "3", "title": "The Great Gatsby", "author": "F. Scott Fitzgerald" }
        ];
        return booksList;
    }

    resource function post books(@http:Payload json payload) returns json|error {
        json newBook = {
            "id": "4",
            "title": check payload.title,
            "author": check payload.author
        };
        return newBook;
    }

    resource function get books/[string id]() returns json | http:NotFound {
        json book = {
            "id": id,
            "title": "Sample Book",
            "author": "Sample Author"
        };
        return book;
    }

    resource function put books/[string id](@http:Payload json payload) returns json|http:NotFound|error {
        json updatedBook = {
            "id": id,
            "title": check payload.title,
            "author": check payload.author
        };
        return updatedBook;
    }

    resource function delete books/[string id]() returns json | http:NotFound {
        json response = { "message": "Book with id " + id + " deleted successfully." };
        return response;
    }
}