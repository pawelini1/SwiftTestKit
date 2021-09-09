import Foundation
import SwiftHttpShellClient

public enum Codec: String {
    case h264
    case hevc
}

public enum Quality: ExpressibleByStringLiteral {
    case low, medium, high, size640x480
    case size960x540, size1280x720, size1920x1080, size3840x2160
    case custom(String)
    
    public init(stringLiteral value: StringLiteralType) {
        self = .custom(value)
    }
    
    var name: String {
        switch self {
        case .low: return "PresetLowQuality"
        case .medium: return "PresetMediumQuality"
        case .high: return "PresetHighestQuality"
        case .size640x480: return "Preset640x480"
        case .size960x540: return "Preset960x540"
        case .size1280x720: return "Preset1280x720"
        case .size1920x1080: return "Preset1920x1080"
        case .size3840x2160: return "Preset3840x2160"
        case .custom(let name): return name
        }
    }
}

public enum Appearance: String {
    case dark
    case light
}

public typealias Path = String

public extension Path {
    static func videoPath(forSimulator simulator: Simulator = .current) -> Path {
        return "~/Library/Caches/VideoRecorder/\(simulator.udid).mov"
    }
}

public extension Command {
    static func startRecordingVideo(inSimulator simulator: Simulator = .current, intoPath videoPath: Path? = nil, codec: Codec = .hevc) -> Command {
        let videoPath = videoPath ?? .videoPath(forSimulator: simulator)
        return Command(
            type: .start(
                command: "mkdir -p $(dirname \(videoPath.escapingSpaces)) && xcrun simctl --set \(simulator.directory.escapingSpaces) io \(simulator.udid.escapingSpaces) recordVideo --codec \(codec.rawValue) -f \(videoPath.escapingSpaces)",
                identifer: videoPath
            ),
            message: "Starting video recording in simulator with '\(codec.rawValue)' codec"
        )
    }
    
    static func stopRecordingVideo(inSimulator simulator: Simulator = .current, intoPath videoPath: Path? = nil, completion: @escaping (Data) throws -> Void) throws -> Command {
        let videoPath = videoPath ?? .videoPath(forSimulator: simulator)
        return Command(
            type: .multi(commands: [
                .finishProcess(with: videoPath),
                .convertVideo(at: videoPath),
                try .file(atPath: videoPath, completion: completion)
            ]),
            message: "Stopping video recording in simulator to save it as attachment"
        )
    }

    static func uninstall(application: Application, fromSimulator simulator: Simulator = .current) -> Command {
        return Command(
            type: .shell(
                command: "xcrun simctl --set \(simulator.directory.escapingSpaces) uninstall \(simulator.udid.escapingSpaces) \(application.bundleIdentifer.escapingSpaces)"
            ),
            message: "Uninstalling application with '\(application.bundleIdentifer)'"
        )
    }

    static func convertVideo(at sourcePath: Path, to outputPath: Path? = nil, withQuality quality: Quality = .medium) -> Command {
        return Command(
            type: .shell(
                command: "avconvert -p \(quality.name) -s \(sourcePath.escapingSpaces) -o \((outputPath ?? sourcePath).escapingSpaces) --replace"
            ),
            message: "Converting video to '\(quality.name)' quality"
        )
    }
    
    static func set(appearance: Appearance, inSimulator simulator: Simulator = .current) -> Command {
        return Command(
            type: .shell(
                command: "xcrun simctl --set \(simulator.directory.escapingSpaces) ui \(simulator.udid.escapingSpaces) appearance  \(appearance.rawValue)"
            ),
            message: "Setting \(appearance.rawValue) appearance in simulator"
        )
    }
    
    static func finishProcess(with identifer: ProcessIdentifer) -> Command {
        return Command(
            type: .finish(
                identifer: identifer
            ),
            message: "Finishing process with identifer: \(identifer)"
        )
    }
    
    static func file(atPath path: Path, completion: @escaping (Data) throws -> Void) rethrows -> Command {
        return Command(
            type: .file(
                atPath: path,
                completion: completion
            ),
            message: "Downloading file from '\(path)'"
        )
    }
}
