import XCTest

public struct Simulator {
    static public var current: Simulator {
        do {
            let udid = try environmentVariable(for: "SIMULATOR_UDID")
            return Simulator(
                udid: udid,
                directory: try environmentVariable(for: "HOME").upUntil(text: udid)
            )
        } catch {
            fatalError("Could not determine the details of currently used simulator. Error: \(error)")
        }
    }
    
    public let udid: String
    public let directory: String
    
    public init(udid: String, directory: String) {
        self.udid = udid
        self.directory = directory
    }
}
