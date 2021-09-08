import Foundation
import XCTest
import SwiftHttpShellClient
import MobileCoreServices
import Promises

public extension XCTestCase {
    func recordVideo(shouldFailOnError: Bool = false) {
        let videoRecorder = VideoRecorder(shell: self.httpShell)
        recordVideo(using: videoRecorder, shouldFailOnError: shouldFailOnError)
    }
    
    func recordVideo(using recorder: VideoRecorder, shouldFailOnError: Bool = false) {
        do {
            var recording: Recording!
            try XCTContext.runActivity(named: "Starting video recording") { activity in
                recording = try recorder.startRecording(inSimulator: .current())
            }
            addTeardownBlock { [weak self] in
                guard let self = self else { return }
                do {
                    try XCTContext.runActivity(named: "Finishing video recording") { activity in
                        let attachment = try recorder.finishRecording(recording)
                        self.add(attachment)
                    }
                } catch {
                    self.record("Finishing video recording failed: \(error)", treatAsError: shouldFailOnError)
                }
            }
        } catch {
            self.record("Starting video recording failed: \(error)", treatAsError: shouldFailOnError)
        }
    }
}

public struct Recording {
    public let processIdentifer: String
    public let videoPath: String
    
    public init(processIdentifer: String, videoPath: String) {
        self.processIdentifer = processIdentifer
        self.videoPath = videoPath
    }
}

public class VideoRecorder {
    public enum VideoRecorderError: Error {
        case recordingStartFailed(Error)
    }
    
    private let shell: HttpShell
    private let videosCachePath: String
    
    init(shell: HttpShell, videosCachePath: String = "~/Library/Caches/VideoRecorder") {
        self.shell = shell
        self.videosCachePath = videosCachePath
    }
    
    func startRecording(inSimulator simulator: Simulator) throws -> Recording {
        let videoDirectory = videosCachePath.appending("/\(simulator.udid)")
        let videoPath = "\(videoDirectory)/\(UUID().uuidString).mov"
        let process = try shell.start (
            .recordVideo(ofSimulator: simulator, intoPath: videoPath)
        )
        return Recording(processIdentifer: process.identifer, videoPath: videoPath)
    }
    
    func finishRecording(_ recording: Recording) throws -> XCTAttachment {
        let _ = try shell.finish(recording.processIdentifer)
        let _ = try shell.run(.convertVideo(at: recording.videoPath, withQuality: .medium))
        return XCTAttachment(data: try shell.file(recording.videoPath), uniformTypeIdentifier: kUTTypeQuickTimeMovie as String)
    }
}
