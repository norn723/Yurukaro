import SwiftUI

@main
struct YurukaroApp: App {

    /// アプリ全体で使うデータストア
    @StateObject private var appDataStore = AppDataStore()

    var body: some Scene {
        WindowGroup {

            /// アプリの最初の画面
            InitialSetupStartView()
                .environmentObject(appDataStore)

        }
    }
}
