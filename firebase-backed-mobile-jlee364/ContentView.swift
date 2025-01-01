import SwiftUI

struct ContentView: View {
    var body: some View {
        Blog()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(FireBasedBlogAuth())
            .environmentObject(FireBasedBlogArticle())
    }
}
