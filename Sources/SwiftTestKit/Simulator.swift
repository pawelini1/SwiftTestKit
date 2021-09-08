import XCTest

public struct Simulator {
    public enum SimulatorError: Error {
        case missingEnvironmentVariable(String)
        case missingSimulatorUDID
    }
    
    public let udid: String
    public let directory: String
    
    public init(udid: String, directory: String) {
        self.udid = udid
        self.directory = directory
    }
    
    public static func current() throws -> Simulator {
        let udid = try environmentVariable(for: "SIMULATOR_UDID")
        return Simulator(
            udid: udid,
            directory: try environmentVariable(for: "HOME").upUntil(text: udid)
        )
    }
}
