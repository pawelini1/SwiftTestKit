import XCTest
import SwiftHttpShellClient

extension XCTestCase {
    internal var httpShell: HttpShell {
        guard let httpShellUrlString = ProcessInfo.processInfo.environment["HTTP_SHELL_URL"] else {
            fatalError("Could not determine the URL for HttpShell. Make sure you have 'HTTP_SHELL_URL' environment variable available for test target.")
        }
        guard let httpShellUrl = URL(string: httpShellUrlString) else {
            fatalError("Could not create valid URL with: \(httpShellUrlString)")
        }
        return .init(baseUrl: httpShellUrl)
    }
    
    @discardableResult
    public func shell(_ commands: Command...) throws -> OutputResponse {
        OutputResponse(output: try commands.reduce(String()) { output, command in
            output.appending(try httpShell.run(command).output)
        })  
    }
}

