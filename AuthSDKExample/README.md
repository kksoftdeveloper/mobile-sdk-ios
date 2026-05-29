# AuthSDKExample

**AuthSDKExample** is a demonstration project designed to illustrate how you can integrate and effectively utilize the **AuthSDK**, a SwiftUI-based authentication framework for iOS.

This example demonstrates a clean implementation of a login functionality, showing how to authenticate users via username/password using AuthSDK.

---

## 🚀 Overview

This example clearly demonstrates:

- ✅ How to integrate and use **AuthSDK** in your SwiftUI project.
- ✅ Implementation of the login flow using **username/password authentication**.
- ✅ Handling authentication state (`isAuthenticated`) and error messages.
- ✅ Utilizing SwiftUI and MVVM architecture for clear separation of concerns.

---

## 🗂 Project Structure

Here's the structure of the AuthSDKExample project:

```
AuthSDKExample
│
├── Sources
│   │   └── AuthSDKExampleApp.swift  ← Main Application View
│   ├── Views
│   │   ├── LoginView.swift          ← SwiftUI Login Screen
│   │
│   ├── ViewModels
│   │   └── AuthViewModel.swift      ← Handles authentication logic
│   │
│   └── Supporting Files
│       └── AuthSDKExampleApp.swift  ← App entry point
│
├── AuthSDK (Dependency)
    └── Custom authentication framework built in SwiftUI.
```
---

## ⚙️ XcodeGen Usage

**XcodeGen** simplifies your Xcode project management.

### 📌 How to install XcodeGen

```bash
brew install xcodegen
```

### ✅ Generate Xcode Project

After modifying `project.yml`, regenerate your Xcode project:

```bash
xcodegen generate
```

Then open the project:

```bash
open AuthSDK.xcodeproj
```

---

## 📦 Integration

The example app integrates **AuthSDK** via Swift Package Manager.

- Add the local Swift package dependency by following these steps in Xcode:

```
File → Add Packages → Add Local... → select "AuthSDK" folder
```

- Import the SDK into your SwiftUI views or ViewModels:

```swift
import AuthSDK
```

---

## 🔐 Using Login Function (Example)

**Step 1: Create `AuthViewModel`**

Your `AuthViewModel.swift` manages the logic for user login:

```swift
import SwiftUI
import AuthSDK
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    
    private let authManager: AuthManager = DefaultAuthManager()
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func login() {
        authManager.login(username: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.isAuthenticated = false
                    self.errorMessage = error.localizedDescription
                    print("❌ Login failed:", error)
                }
            }, receiveValue: { session in
                self.isAuthenticated = true
                print("✅ Login Success: \(session.accessToken)")
            })
            .store(in: &cancellables)
    }
}
```

**Step 2: Use `AuthViewModel` in SwiftUI View**

In your `LoginView.swift`:

```swift
import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login") {
                viewModel.login()
            }
            .padding()

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            if viewModel.isAuthenticated {
                Text("🎉 Login Successful!")
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}
```

---

## 🛠 Requirements

- iOS 15.0+
- Xcode 15.0+
- Swift 5.9+

---

## 📚 Dependencies

- [AuthSDK](..): Your custom authentication SDK built using SwiftUI and Combine.

---

## 📄 License

AuthSDKExample is available under the MIT license. See the [LICENSE](LICENSE) file for details.

---

🎉 **Happy Coding!**
