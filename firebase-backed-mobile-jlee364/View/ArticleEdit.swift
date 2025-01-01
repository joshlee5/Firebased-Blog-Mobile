import SwiftUI

struct ArticleEdit: View {
    @EnvironmentObject var articleService: FireBasedBlogArticle

    @Binding var articles: [Article]
    @Binding var writing: Bool
    
    @State var title = ""
    @State var articleBody = ""
    
    var article: Article
    
    func editArticle() async {
        Task {
            do {
                let articleId = try await articleService.updateArticle(article: article, title: title, body: articleBody)
                writing = false
                if let index = articles.firstIndex(where: { $0.id == articleId }) {
                                articles[index] = Article(id: articleId, title: article.title, date: article.date, body: article.body)
                    }
            } catch {
                print("Article editted successfully.")
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
                .navigationTitle("Edit Current Article")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            writing = false
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                await editArticle()
                            }
                        }
                        .disabled(title.isEmpty || articleBody.isEmpty)
                    }
                }
            }
        }
}
