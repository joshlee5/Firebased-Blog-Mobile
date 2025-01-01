/**
 * ArticleList displays a list of articles, toggling between the list and a chosen article.
 */

import SwiftUI

struct ArticleList: View {
    @EnvironmentObject var auth: FireBasedBlogAuth
    @EnvironmentObject var articleService: FireBasedBlogArticle

    @Binding var requestLogin: Bool

    @State var articles: [Article]
    @State var error: Error?
    @State var fetching = false
    @State var writing = false
    @State var searchText = ""

    var body: some View {
        NavigationView {
            ZStack() {
                LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom)
                                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if fetching {
                        ProgressView()
                    } else if error != nil {
                        Text("Something went wrong…we wish we can say more 🤷🏽")
                    } else if articles.count == 0 {
                        VStack {
                            Spacer()
                            Text("There are no articles.")
                            Spacer()
                        }
                    } else {
                        List(articles) { article in
                            NavigationLink {
                                ArticleDetail(articles: $articles, article: article)
                            } label: {
                                ArticleMetadata(article: article)
                            }
                        }
                    }
                }
                .navigationTitle("FireBasedBlog: Mobile Edition")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if auth.user != nil {
                            Button("New Article") {
                                writing = true
                            }
                            .background(Color(.green))
                            .padding()
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if auth.user != nil {
                            Button("Sign Out") {
                                do {
                                    try auth.signOut()
                                } catch {
                                    print("Something went wrong with sign out.")
                                }
                            }
                        } else {
                            Button("Sign In") {
                                requestLogin = true
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $writing) {
                ArticleEntry(articles: $articles, writing: $writing)
            }
            .task (id: searchText) {
                fetching = true

                do {
                    articles = try await searchText == "" ? articleService.fetchArticles() : articleService.searchArticles(query: searchText)
                    fetching = false
                } catch {
                    self.error = error
                    fetching = false
                }
            }.searchable(text: $searchText)
            .onAppear(perform: {
                print("Live \(searchText)")
            })
            .onSubmit {
                print("Submit \(searchText)")
            }
        }
    }
}

struct ArticleList_Previews: PreviewProvider {
    @State static var requestLogin = false

    static var previews: some View {
        ArticleList(requestLogin: $requestLogin, articles: [])
            .environmentObject(FireBasedBlogAuth())

        ArticleList(requestLogin: $requestLogin, articles: [
            Article(
                id: "12345",
                title: "Preview",
                date: Date(),
                body: "Lorem ipsum dolor sit something something amet"
            ),

            Article(
                id: "67890",
                title: "Some time ago",
                date: Date(timeIntervalSinceNow: TimeInterval(-604800)),
                body: "Duis diam ipsum, efficitur sit amet something somesit amet"
            )
        ])
        .environmentObject(FireBasedBlogAuth())
        .environmentObject(FireBasedBlogArticle())
    }
}
