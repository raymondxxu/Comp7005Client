import Foundation
import Socket
import CommonLib
@main
public struct Client {
    
    public static func main() {
        let argParser = ArgParser.shared

        do {
            try argParser.parse()
        } catch(let error) {
            print(error)
            exit(-1)
        }
        let port: UInt16 = argParser.portNumber ?? 2222
        let socketManager = SocketManager(isForServer: false, serverIP: argParser.serverIp!, port: port)
        let fileManager = FileManager.shared
        do {
            try socketManager.createSocket()
        } catch {
            print("Failed to create Socket")
            exit(-1)
        }
        print("socket created")
        do {
            try socketManager.connect()
        } catch {
            print("Failed to connect to server")
            exit(-1)
        }
        print("connection establihsed")
        argParser.targetFileNames.forEach { testText in
           
            let fileName = testText as NSString
            var fileContent: NSString
            do{
                fileContent = try fileManager.readingFile(with: fileName as String) as NSString
            } catch {
                print("Reading file with error")
                exit(-1)
            }
            let targetFile = NSString(format: "%@_%@",testText, fileContent)
            let textCStr = targetFile.cString(using: String.Encoding.ascii.rawValue)!
            let textLength = Int(targetFile.lengthOfBytes(using: String.Encoding.ascii.rawValue))
            let sendStatusCode = write(socketManager.socketFD!, textCStr, textLength)
            guard sendStatusCode != -1 else {
                print("failed to send")
                exit(-1)
            }

            print("send: \(testText) successfully")
            Thread.sleep(forTimeInterval: 0.25)
        }
        let nullptr = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
        nullptr.pointee = 0
        write(socketManager.socketFD!, nullptr, 1)
//        close(socketManager.socketFD!)
    }
}
