import SwiftHttpShellClient

public extension Command {
    enum Codec: String {
        case h264
        case hevc
    }
    
    static func recordVideo(ofSimulator simulator: Simulator, intoPath path: String, codec: Codec = .hevc) -> Command {
        return .init(command: "mkdir -p $(dirname \(path.escapingSpaces)) && xcrun simctl --set \(simulator.directory.escapingSpaces) io \(simulator.udid.escapingSpaces) recordVideo --codec \(codec.rawValue) -f \(path.escapingSpaces)")
    }
    
    static func uninstall(application: Application, fromSimulator simulator: Simulator) -> Command {
        return .init(command: "xcrun simctl --set \(simulator.directory.escapingSpaces) uninstall \(simulator.udid.escapingSpaces) \(application.bundleIdentifer.escapingSpaces)")
    }
    
    enum Quality: ExpressibleByStringLiteral {
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
    
    static func convertVideo(at sourcePath: String, to outputPath: String? = nil, withQuality quality: Quality) -> Command {
        return .init(command: "avconvert -p \(quality.name) -s \(sourcePath.escapingSpaces) -o \((outputPath ?? sourcePath).escapingSpaces) --replace")
    }
    
    enum Appearance: String {
        case dark
        case light
    }
    
    static func set(appearance: Appearance, inSimulator simulator: Simulator) -> Command {
        return .init(command: "xcrun simctl --set \(simulator.directory.escapingSpaces) ui \(simulator.udid.escapingSpaces) appearance  \(appearance.rawValue)")
    }
}
