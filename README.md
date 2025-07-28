# 🧠 Cluster Headache Tracker iOS

Cluster Headache Tracker iOS is a Hotwire Native wrapper for the [Cluster Headache Tracker](https://github.com/crmne/cluster-headache-tracker) web application. This app uses [Hotwire Native for iOS](https://github.com/hotwired/hotwire-native-ios) to provide the web app experience within a native iOS app shell.

## 🎯 Purpose

The main reason for creating this iOS app is to increase accessibility and visibility of the Cluster Headache Tracker. While the web application functions as a Progressive Web App (PWA), many users are unfamiliar with PWAs or how to add them to their home screens. This native iOS wrapper provides a familiar way for users to download and access the app through the App Store.

## 🚀 Features

- 📱 Access the Cluster Headache Tracker web app through a familiar iOS app interface
- 📊 View and interact with headache logs and charts
- 🔒 Secure authentication and data storage (handled by the web app)

## 🛠 Requirements

- iOS 18.0+
- Xcode 15.0+
- Swift 5.0+

## 📲 Installation

1. Clone the repository:
   ```
   git clone https://github.com/crmne/cluster-headache-tracker-ios.git
   ```

2. Open the `Cluster Headache Tracker.xcodeproj` file in Xcode.

3. Build and run the project on your iOS device or simulator.

## 🔧 Development Setup

### Git Hooks

This project uses pre-commit hooks to ensure code quality. To set them up:

1. Install pre-commit and required tools:
   ```bash
   brew install pre-commit swiftlint swiftformat
   ```

2. Install the git hooks:
   ```bash
   pre-commit install
   pre-commit install --hook-type pre-push
   ```

The following checks will run automatically:
- **Pre-commit**: SwiftLint, SwiftFormat, trailing whitespace removal, file size checks
- **Pre-push**: Unit tests and build verification

To run the hooks manually:
```bash
pre-commit run --all-files
```

## 🔗 Related Projects

- [Cluster Headache Tracker (Web)](https://github.com/crmne/cluster-headache-tracker): The main web application that this iOS app wraps.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for more details on how to get started.

## 📄 License

Cluster Headache Tracker iOS is released under the [GNU General Public License v3.0 (GPL-3.0)](LICENSE).

## 🔒 Privacy

This iOS app provides access to the same web application as the browser version, maintaining the same privacy principles. No additional personally identifiable information is collected or stored. All data handling occurs on the EU-based servers of the main Cluster Headache Tracker application.

## 🍕 Support the Project

If you find this tool valuable, please consider making a donation:

[![Buy me a pizza](https://img.shields.io/badge/Buy%20me%20a%20pizza-%2410-orange?style=for-the-badge&logo=buy-me-a-coffee&logoColor=white)](https://buymeacoffee.com/crmne)

## 🆘 Support

If you encounter any issues or have questions, please [open an issue](https://github.com/crmne/cluster-headache-tracker-ios/issues) on GitHub.

## 🙏 Acknowledgements

- [Hotwire Native for iOS](https://github.com/hotwired/hotwire-native-ios) for enabling this web-to-native wrapper.
- All contributors and users who help improve this project.
