/**
 * FireBasedBlogArticle is the article service—it completely hides the data store from the rest of the app.
 * No other part of the app knows how the data is stored. If anyone wants to read or write data, they have
 * to go through this service.
 */
import Foundation

import Firebase
import FirebaseCore
import FirebaseFirestore

let COLLECTION_NAME = "articles"
let PAGE_LIMIT = 20

enum ArticleServiceError: Error {
    case mismatchedDocumentError
    case unexpectedError
}

class FireBasedBlogArticle: ObservableObject {
    private let db = Firestore.firestore()
    
    // Some of the iOS Firebase library’s methods are currently a little…odd.
    // They execute synchronously to return an initial result, but will then
    // attempt to write to the database across the network asynchronously but
    // not in a way that can be checked via try async/await. Instead, a
    // callback function is invoked containing an error _if it happened_.
    // They are almost like functions that return two results, one synchronously
    // and another asynchronously.
    //
    // To deal with this, we have a published variable called `error` which gets
    // set if a callback function comes back with an error. SwiftUI views can
    // access this error and it will update if things change.
    @Published var error: Error?
    
    func createArticle(article: Article) async throws -> String {
        // addDocument is one of those “odd” methods.
        let ref = try await db.collection(COLLECTION_NAME).addDocument(data: [
            "title": article.title,
            "date": article.date, // This gets converted into a Firestore Timestamp.
            "body": article.body,
            "id": article.id
        ])
        
        // If we don’t get a ref back, return an empty string to indicate “no ID.”
        return ref.documentID
    }
    
    func updateArticle(article: Article, title: String, body: String) async throws -> String {
        let articleID = article.id
        let ref = db.collection(COLLECTION_NAME).document(articleID)
        
        try await ref.updateData([
                "title": title,
                "body": body
                // date and id do not get updated since we are editting current article
            ])
        
        return ref.documentID
    }
    
    func removeArticle(articleID: String) async throws {
        let ref = db.collection(COLLECTION_NAME).document(articleID)
        do {
            try await ref.delete()
            print("Successfully deleted!")
        }
        catch {
            print("Error deleting article.")
        }
        
    }
    
    // Note: This is quite unsophisticated! It only gets the first PAGE_LIMIT articles.
    // In a real app, you implement pagination.
    func fetchArticles() async throws -> [Article] {
        let articleQuery = db.collection(COLLECTION_NAME)
            .order(by: "date", descending: true)
            .limit(to: PAGE_LIMIT)
        
        // Fortunately, getDocuments does have an async version.
        //
        // Firestore calls query results “snapshots” because they represent a…wait for it…
        // _snapshot_ of the data at the time that the query was made. (i.e., the content
        // of the database may change after the query but you won’t see those changes here)
        let querySnapshot = try await articleQuery.getDocuments()
        
        return try querySnapshot.documents.map {
            print("\($0.documentID) => \($0.data())")
            
            // This is likely new Swift for you: type conversion is conditional, so they
            // must be guarded in case they fail.
            guard let title = $0.get("title") as? String,
                  
                    // Firestore returns Swift Dates as its own Timestamp data type.
                  let dateAsTimestamp = $0.get("date") as? Timestamp,
                  let body = $0.get("body") as? String else {
                throw ArticleServiceError.mismatchedDocumentError
            }
            
            return Article(
                id: $0.documentID,
                title: title,
                date: dateAsTimestamp.dateValue(),
                body: body
            )
        }
    }
        
    func searchArticles(query: String) async throws -> [Article] {
        // searchQuery has to match the exact capitalization and spacing of the article title.
        let searchQuery = query
        
        let querySnapshot = try await db.collection(COLLECTION_NAME)
        // Wrote below code with some help from ChatGPT
            .whereField("title", isGreaterThanOrEqualTo: searchQuery)
            .whereField("title", isLessThanOrEqualTo: "\(searchQuery)\u{f8ff}")
                    .getDocuments()
        
        return querySnapshot.documents.compactMap { document -> Article? in
                try? document.data(as: Article.self)
            }
    }
}
