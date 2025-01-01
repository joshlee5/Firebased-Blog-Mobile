/**
 * ArticleDetail displays a single article model object.
 */
import SwiftUI

struct ArticleDetail: View {
    @EnvironmentObject var articleService: FireBasedBlogArticle
    
    @Binding var articles: [Article]
    @State private var isEditing = false
    @State private var isBodyVisible = false
    
    var article: Article
    
    func deleteArticle (current_article: Article) async {
        let articleId = current_article.id
        
        Task {
            do {
                if let index = articles.firstIndex(where: { $0.id == articleId }) {
                                articles.remove(at: index)
                    }
                
                try await articleService.removeArticle(articleID: articleId)
            }
            catch {
                print("Deletion unsuccessful")
            }
        }
    }

    var body: some View {
        VStack {
            ArticleMetadata(article: article)
                .padding()

            Text(article.body).padding()
                .border(Color(.black))
                .opacity(isBodyVisible ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.isBodyVisible = true
                    }
                }
            Spacer()
            FireShapeSymbol()
            Spacer()
            HStack () {
                Button("Delete") {
                    Task {
                        await deleteArticle(current_article: article)
                    }
                }
                .padding()
                .background(Color(.red))
                .border(Color(.black))
                Divider()
                NavigationLink(destination: ArticleEdit(articles: $articles, writing: $isEditing, article: article), isActive: $isEditing) {
                        EmptyView()
                    }
                    Button("Edit") {
                        isEditing = true
                    }
                    .padding()
                    .background(Color(.yellow))
                    .border(Color(.black))
            }
        }
        .background(Color(.lightGray))
    }
}

//struct ArticleDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ArticleDetail(articles: $articles, article: Article(
//            id: "12345",
//            title: "Preview",
//            date: Date(),
//            body: "Lorem ipsum dolor sit something something amet"
//        ))
//    }
//}
