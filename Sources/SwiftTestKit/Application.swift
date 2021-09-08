import XCTest

public struct Application {
    public let bundleIdentifer: String
    
    public init(bundleIdentifer: String) {
        self.bundleIdentifer = bundleIdentifer
    }
}

extension Application: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(bundleIdentifer: value)
    }
}
