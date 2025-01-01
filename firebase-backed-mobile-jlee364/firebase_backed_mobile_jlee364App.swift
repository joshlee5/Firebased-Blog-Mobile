import SwiftUI
import FirebaseCore

@main
struct firebase_backed_mobile_jlee364App: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(FireBasedBlogAppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
          ContentView()
      }
      .environmentObject(FireBasedBlogAuth())
      .environmentObject(FireBasedBlogArticle())
    }
  }
}

