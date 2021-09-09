import Foundation
import XCTest
import MobileCoreServices

extension String {
    enum StringError: Error {
        case noSubstring(String, in: String)
    }
    
    func upUntil(text: String) throws -> String {
        guard let range = self.range(of: text) else {
            throw StringError.noSubstring(text, in: self)
        }
        return "\(self[startIndex..<range.lowerBound])"
    }
}

public extension XCTestCase {
    func recordMessage(_ message: String) {
        XCTContext.runActivity(named: message, block: { _ in })
    }
    
    func recordIssue(_ description: String, type: XCTIssue.IssueType = .system) {
        record(XCTIssue(type: type, compactDescription: description))
    }
    
    func record(_ message: String, treatAsError: Bool, type: XCTIssue.IssueType = .system) {
        guard treatAsError else {
            recordMessage(message)
            return
        }
        recordIssue(message, type: type)
    }
    
    func addVideoAttachment(_ data: Data) {
        add(XCTAttachment(data: data, uniformTypeIdentifier: kUTTypeQuickTimeMovie as String))
    }
}

public enum EnvironmentVariableError: Error {
    case missingEnvironmentVariable(String)
}

public func environmentVariable(for key: String) throws -> String {
    guard let value = ProcessInfo.processInfo.environment[key] else {
        throw EnvironmentVariableError.missingEnvironmentVariable(key)
    }
    return value
}
