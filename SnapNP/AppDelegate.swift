import UIKit
import SpotifyLogin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let redirectURL: URL = URL(string: "snapcover://")!
        SpotifyLogin.shared.configure(clientID: "a8366dcd478f4ffeadbb2fa19c416614",
                                      clientSecret: "233254af719e45f59a36a16d634ee770",
                                      redirectURL: redirectURL)
        Thread.sleep(forTimeInterval: 3)

        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handled = SpotifyLogin.shared.applicationOpenURL(url) { _ in }
        return handled
    }
    
}
