import Foundation
import Socket
import CommonLib
@main
public struct Client {
    
    public static func main() {
        let argParser = ArgParser.senderArgParser
        var initalDataId = 0
        
        do {
            try argParser.parse()
        } catch(let error) {
            print(error)
            exit(-1)
        }
        let port: UInt16 = argParser.portNumber ?? 2222
        let socketManager = SocketManager(isForServer: false, serverIP: argParser.receiverIp!, port: port)
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
        while true {
            let readingLine = readLine()
            if readingLine?.count == 0 {
                break
            }
            let objectData = DataModel(seq: initalDataId, type: .SYN, data: readingLine)
            let cStr = (objectData as JsonStringConvertible).convert()! as NSString
            write(socketManager.socketFD!, cStr.cString(using: String.Encoding.ascii.rawValue), cStr.length)
            initalDataId += 1
            var receivedBuffer = Array<CChar>(repeating: 0, count: 1024)
            let bytes = read(socketManager.socketFD!, &receivedBuffer, 1024)
            let json = (DataModel.convert(from: String(utf8String: receivedBuffer)!) as? DataModel)!
            print(String(cString: receivedBuffer))
            print(json)
        }
        
    }
}
