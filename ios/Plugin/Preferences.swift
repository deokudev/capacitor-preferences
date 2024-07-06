import Foundation

public struct PreferencesConfiguration {
    public enum Group {
        case named(String), cordovaNativeStorage, appGroup(String)
    }

    let group: Group

    public init(for group: Group = .appGroup("group.SharedCapacitorStorage")) {
        self.group = group
    }
}

public class Preferences {
    private let configuration: PreferencesConfiguration

    private var defaults: UserDefaults {
        switch configuration.group {
        case .cordovaNativeStorage, .named:
            return UserDefaults.standard
        case let .appGroup(groupIdentifier):
            guard let defaults = UserDefaults(suiteName: groupIdentifier) else {
                fatalError("Unable to access UserDefaults with app group: \(groupIdentifier)")
            }
            return defaults
        }
    }

    private var prefix: String {
        switch configuration.group {
        case .cordovaNativeStorage:
            return ""
        case let .named(group):
            return group + "."
        case .appGroup:
            return ""
        }
    }

    private var rawKeys: [String] {
        return defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(prefix) }
    }

    public init(with configuration: PreferencesConfiguration = PreferencesConfiguration()) {
        self.configuration = configuration
    }

    public func get(by key: String) -> String? {
        return defaults.string(forKey: applyPrefix(to: key))
    }

    public func set(_ value: String, for key: String) {
        defaults.set(value, forKey: applyPrefix(to: key))
    }

    public func remove(by key: String) {
        defaults.removeObject(forKey: applyPrefix(to: key))
    }

    public func removeAll() {
        for key in rawKeys {
            defaults.removeObject(forKey: key)
        }
    }

    public func keys() -> [String] {
        return rawKeys.map { String($0.dropFirst(prefix.count)) }
    }

    private func applyPrefix(to key: String) -> String {
        return prefix + key
    }
}
