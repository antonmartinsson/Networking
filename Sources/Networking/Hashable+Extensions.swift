import Foundation

public extension Hashable {
    var asQueryItems: [URLQueryItem] {
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
    
    
    var asHeaders: [String: String] {
        let mirror = Mirror(reflecting: self)
        let children: [(String, String)] = mirror.children.compactMap { child in
            guard let label = child.label else { return nil }
            let valueMirror = Mirror(reflecting: child.value)
            if valueMirror.isOptional {
                guard let valueString = valueMirror.valueString else {
                    return nil
                }
                return (label, valueString)
            }
            return (label, "\(child.value)")
        }
        
        let headers = children.reduce(into: [String: String]()) { dict, pair in
            dict[pair.0] = pair.1
        }
        return headers
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
