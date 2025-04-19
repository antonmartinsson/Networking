import Foundation

extension Hashable {
    var queryItems: [URLQueryItem] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap { child in
            guard let label = child.label else { return nil }
            let valueMirror = Mirror(reflecting: child.value)
            if valueMirror.isOptional {
                guard let valueString = valueMirror.valueString else {
                    return nil
                }
                return URLQueryItem(name: label, value: valueString)
            }
            let value = "\(child.value)"
            return URLQueryItem(name: label, value: value)
        }
    }
}

extension Mirror {
    var isOptional: Bool {
        displayStyle == .optional
    }

    var valueString: String? {
        guard !children.isEmpty else {
            return nil
        }
        return children.compactMap { "\($0.value)" }.joined()
    }
}
