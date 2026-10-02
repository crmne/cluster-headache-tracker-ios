import Foundation

private final class BundleToken {}

/// Native strings follow the language picked in the web app (sent with
/// `widget-status`) instead of the device language. Looks the strings up in
/// that language's `.lproj` of the bundle these files are compiled into.
enum Localization {
    static var bundle: Bundle {
        Bundle(for: BundleToken.self)
    }

    static func bundle(for language: String?) -> Bundle {
        guard let language,
              let path = bundle.path(forResource: language, ofType: "lproj"),
              let localized = Bundle(path: path)
        else {
            return bundle
        }
        return localized
    }

    static func string(_ key: String.LocalizationValue, language: String?) -> String {
        String(localized: key, bundle: bundle(for: language))
    }
}
