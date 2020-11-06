import UIKit

public protocol Emptyable {
    static var emptyValue: Self { get }
}

extension Optional where Wrapped: Emptyable {
    public func orEmpty() -> Wrapped {
        switch self {
        case .none:
            return Wrapped.emptyValue
        case .some(let value):
            return value
        }
    }
}

extension String: Emptyable {
    public static var emptyValue: String { return "" }
}

extension Bool: Emptyable {
    public static var emptyValue: Bool { return false }
}

extension UInt: Emptyable {
    public static var emptyValue: UInt { return 0 }
}

extension Int: Emptyable {
    public static var emptyValue: Int { return 0 }
}

extension Float: Emptyable {
    public static var emptyValue: Float { return 0 }
}

extension Double: Emptyable {
    public static var emptyValue: Double { return 0 }
}

extension Decimal: Emptyable {
    public static var emptyValue: Decimal { return 0.0 }
}

extension CGFloat: Emptyable {
    public static var emptyValue: CGFloat { return 0 }
}

extension Array: Emptyable {
    public static var emptyValue: [Element] { return [] }
}

extension Dictionary: Emptyable {
    public static var emptyValue: [Key: Value] { return [:] }
}

extension Date: Emptyable {
    public static var emptyValue: Date { return Date() }
}

extension Data: Emptyable {
    public static var emptyValue: Data { return Data() }
}

extension CGRect: Emptyable {
    public static var emptyValue: CGRect { return .zero }
}

extension KeyedDecodingContainer {
    public func decode<T: Decodable>(_ key: Key, as type: T.Type = T.self) throws -> T {
        return try decode(T.self, forKey: key)
    }

    public func decodeIfPresent<T: Decodable>(_ key: KeyedDecodingContainer.Key) -> T? {
        do {
            let value = try decodeIfPresent(T.self, forKey: key)
            return value
        } catch {
            return nil
        }
    }

    public func decodeOrEmpty<T: Decodable & Emptyable>(_ key: KeyedDecodingContainer.Key) -> T {
        do {
            guard let value = try decodeIfPresent(T.self, forKey: key) else {
                return T.emptyValue
            }
            return value
        } catch {
            return T.emptyValue
        }
    }
}
