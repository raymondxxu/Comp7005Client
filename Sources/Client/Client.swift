import Foundation
import Socket
import CommonLib
@main
public struct Client {
    
    private static func readUserInput() {
        
    }

    public static func main() {
        let argParser = ArgParser.senderArgParser
        var initalDataId = 0
        var sendedData = [DataModel]()
        var sendingData = [DataModel]()
        var receivedData = [Int]()
        var sendingCounts = 0
        var receingCount = 0
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
        
        let readingLine = readLine() ?? ""
        let objectData = DataModel(seq: initalDataId, type: .SYN, data: readingLine)
        sendedData.append(objectData)
        var lastReceivedId = -1
        var addMissingData = true
        while let current = sendedData.popLast() {
            sendingData.append(current)
            let cStr = (current as JsonStringConvertible).convert()! as NSString
            print(cStr)
            sendingCounts += 1
            let sendingBytes = write(socketManager.socketFD!, cStr.cString(using: String.Encoding.ascii.rawValue), cStr.length)
            print("sending \(sendingBytes)")
            initalDataId += 1
            Thread.sleep(forTimeInterval: 0.5)
            var receivedBuffer = Array<CChar>(repeating: 0, count: 1024)
            var timeout = timeval(tv_sec: 1, tv_usec: 0)
            setsockopt(socketManager.socketFD!, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout.size(ofValue: timeout)))
            let bytes = read(socketManager.socketFD!, &receivedBuffer, 1024)
            if bytes > 0 {
                receingCount += 1
            }
            if let json = (DataModel.convert(from: String(utf8String: receivedBuffer)!) as? DataModel) {
                receivedData.append(json.id)
            }
            if let readingLine = readLine() {
                let objectData = DataModel(seq: initalDataId, type: .SYN, data: readingLine)
                sendedData.append(objectData)
            } else {
                for sendingDatum in sendingData {
                    if !receivedData.contains(sendingDatum.id) {
                         sendedData.append(sendingDatum)
                    } else {
                        sendedData.removeAll{ $0.id == sendingDatum.id }
                    }
                }
            }
            print("number of packets sended: \(sendingCounts)")
            print("number of packets received: \(receingCount)")
            print("Actual Drop \(abs(100 - Double(receingCount) / Double(sendingCounts) * 100))%")
        }
        
    }
}
