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
    
    func api(_ apiCalls: API...) throws {
        let urlSession = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        try apiCalls.forEach { apiCall in
            return try XCTContext.runActivity(named: apiCall.message) { activity in
                var data: Data?, response: URLResponse?, error: Error?
                let semaphore = DispatchSemaphore(value: 0)
                urlSession.dataTask(with: try apiCall.request.urlRequest()) {
                    data = $0; response = $1; error = $2
                    semaphore.signal()
                }.resume()
                
                let _ = semaphore.wait(timeout: .distantFuture)
                try apiCall.onResponse(data, response, error)
            }
        }
    }
}

extension XCTestCase: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        //Trust the certificate even if not valid
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
}

