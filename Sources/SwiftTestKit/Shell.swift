import XCTest
import SwiftHttpShellClient

public extension XCTestCase {
    enum ShellError: Error {
        case shellCreationFailed(String)
    }
    
    func shell(_ commands: Command...) throws {
        guard let httpShellUrlString = ProcessInfo.processInfo.environment["HTTP_SHELL_URL"] else {
            throw ShellError.shellCreationFailed("Could not determine the URL for HttpShell. Make sure you have 'HTTP_SHELL_URL' environment variable available for test target.")
        }
        guard let httpShellUrl = URL(string: httpShellUrlString) else {
            throw ShellError.shellCreationFailed("Could not create valid URL with: \(httpShellUrlString)")
        }
        let httpShell = HttpShell(baseUrl: httpShellUrl)
        
        try commands.forEach { command in
            let _ = try httpShell.shell(command)
        }
    }
}

