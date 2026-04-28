import SwiftUI

struct MainTabView: View {

    @EnvironmentObject var appDataStore: AppDataStore
    @State private var selectedTabIndex: Int = 0

    var body: some View {
        TabView(selection: $selectedTabIndex) {

            HomeView()
                .environmentObject(appDataStore)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            CalendarView()
                .environmentObject(appDataStore)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(1)

            SettingsView()
                .environmentObject(appDataStore)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .onAppear {
            print("===== MainTabView onAppear START =====")
            print("selectedTabIndex = \(selectedTabIndex)")
            print("===== MainTabView onAppear END =====")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppDataStore())
}
