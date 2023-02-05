import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

extension UserDefaults {
  var openAIAPIKey: String? {
    get { string(forKey: #function) }
    set { set(newValue, forKey: #function) }
  }
}

// MARK: - Settings

struct Settings: ReducerProtocol {
  struct State: Equatable {
    var modelSelector = ModelSelector.State()
  }

  enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case modelSelector(ModelSelector.Action)
    case task
  }

  var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Scope(state: \.modelSelector, action: /Action.modelSelector) {
      ModelSelector()
    }

    Reduce { _, action in
      switch action {
      case .task:
        return .none

      default:
        return .none
      }
    }
  }
}

// MARK: - SettingsView

struct SettingsView: View {
  @ObserveInjection var inject

  let store: StoreOf<Settings>
  @ObservedObject var viewStore: ViewStoreOf<Settings>

  init(store: StoreOf<Settings>) {
    self.store = store
    viewStore = ViewStore(store)
  }

  var body: some View {
    NavigationView {
      List {
        Section(header: Text("Transcription")) {
          NavigationLink(destination: ModelSelectorView(store: store.scope(state: \.modelSelector, action: Settings.Action.modelSelector))) {
            HStack(spacing: .grid(4)) {
              Text("🤖")
              Text("Transcription Model")
            }
          }
        }
        .listRowBackground(Color.DS.Background.secondary)
      }
      .screenRadialBackground()
    }
    .scrollContentBackground(.hidden)
    .navigationBarTitle("Settings")
    .task { viewStore.send(.task) }
    .enableInjection()
  }
}

// MARK: - Settings_Previews

struct Settings_Previews: PreviewProvider {
  struct ContentView: View {
    var body: some View {
      SettingsView(
        store: Store(
          initialState: Settings.State(),
          reducer: Settings()
        )
      )
    }
  }

  static var previews: some View {
    ContentView()
  }
}
