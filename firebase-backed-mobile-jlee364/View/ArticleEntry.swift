/**
 * ArticleEntry is a view for creating a new article.
 */
import SwiftUI

struct ArticleEntry: View {
    @EnvironmentObject var articleService: FireBasedBlogArticle

    @Binding var articles: [Article]
    @Binding var writing: Bool
    
    @State var title = ""
    @State var articleBody = ""

    func submitArticle() async {
        // We take a two-part approach here: this first part sends the article to
        // the database. The `createArticle` function gives us its ID.
        Task {
            do {
                let articleId = try await articleService.createArticle(article: Article(
                    id: UUID().uuidString, // Temporary, only here because Article requires it.
                    title: title,
                    date: Date(),
                    body: articleBody
                ))
                
                // As an optimization, instead of reloading all of the entries again, we
                // just _add a new Article in memory_. This makes things appear faster and
                // if the database creation worked fine, upon the next load we would then
                // get the real stored Article.
                //
                // There is some risk here—in the event of an error we might mistakenly
                // provide the wrong impression that the Article was stored when it actually
                // wasn’t. More sophisticated code can look at the published `error` variable
                // in the article service and provide some feedback if that error becomes
                // non-nil.
                articles.append(Article(
                    id: articleId,
                    title: title,
                    date: Date(),
                    body: articleBody
                ))

                writing = false
            } catch {
             print("Error has occurred.")
            }
        }
    }

    var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Title")) {
                        TextField("", text: $title)
                    }
                    
                    Section(header: Text("Body")) {
                        TextEditor(text: $articleBody)
                            .frame(minHeight: 256, maxHeight: .infinity)
                    }
                }
                .navigationTitle("New Article")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            writing = false
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Submit") {
                            Task {
                                await submitArticle()
                            }
                        }
                        .disabled(title.isEmpty || articleBody.isEmpty)
                    }
                }
            }
        }
}

struct ArticleEntry_Previews: PreviewProvider {
    @State static var articles: [Article] = []
    @State static var writing = true
    
    static var previews: some View {
        ArticleEntry(articles: $articles, writing: $writing)
            .environmentObject(FireBasedBlogArticle())
    }
}
