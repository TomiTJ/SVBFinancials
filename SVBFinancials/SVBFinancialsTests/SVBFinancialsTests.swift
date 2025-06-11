import SwiftUI
import SwiftData

@main
struct SVB_AppApp: App {
    @StateObject private var favouriteVM = FavouriteViewModel()
    @StateObject private var homeVM = HomeViewModel()

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UINavigationController.self])
            .tintColor = UIColor(Color.themePrimary)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Alert.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("couldnt create model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.themeBackground
                    .edgesIgnoringSafeArea(.all)

                HomeView()
                    .environmentObject(favouriteVM)
                    .environmentObject(homeVM)
                    .modelContainer(sharedModelContainer)
                    .accentColor(.themePrimary)
            }
        }
    }
}
