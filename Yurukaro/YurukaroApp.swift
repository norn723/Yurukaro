import SwiftUI

@main
struct YurukaroApp: App {

    @StateObject private var appDataStore = AppDataStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if appDataStore.settings.hasCompletedInitialSetup {
                    MainTabView()
                } else {
                    InitialSetupStartView()
                }
            }
            .environmentObject(appDataStore)
        }
    }
}
