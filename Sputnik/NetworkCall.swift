//
//  Network.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-07-09.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import SwiftUI
import Network

class NetworkCall: ObservableObject {
    var completionHandler: ((ConnectionResult) -> ())?
    let connection: NWConnection
    let queue = DispatchQueue(label: "Gemini connection Q")
    var buffer: Data = Data()
    let url: GeminiURL
    
    init(url: GeminiURL) {
        self.url = url
        let tlsOptions = NWProtocolTLS.Options()
        
        sec_protocol_options_set_verify_block(tlsOptions.securityProtocolOptions, { (_, _, sec_protocol_verify_complete) in
            sec_protocol_verify_complete(true)
        }, DispatchQueue(label: "gemini"))
        
        let tcpOptions = NWProtocolTCP.Options()
        let parameters = NWParameters(tls: tlsOptions, tcp: tcpOptions)
        let host = NWEndpoint.Host(url.host)
        let endpointPort = NWEndpoint.Port(rawValue: url.port)!

        connection = NWConnection(host: host, port: endpointPort, using: parameters)
    }
    
    public func activate(onSuccess completionHandler: @escaping (ConnectionResult) -> ()) {
        connection.stateUpdateHandler = stateDidChange(to:)
        connection.start(queue: queue)
        self.completionHandler = completionHandler
        setupDocumentReceipt()
    }
    
    private func stateDidChange(to state: NWConnection.State) {
        switch state {
        case .ready:
            let urlStringRaw = url.toString()
            // Fix for RFC-3896 section 5.2.4
            let urlString = urlStringRaw.replacingOccurrences( of: #"\/\.\.\/(A-Z)\w+"#,
                                                               with: "/",
                                                               options: .regularExpression)
            let contentString = "\(urlString)\r\n"
            print("connecting to \(urlString) ...")
            connection.send(content: contentString.data(using: .utf8)!, completion: .contentProcessed( { error in
                if let error = error {
                    print("connection failed with error: \(error)")
                }
            }))
            
        case .failed(let error):
            print("connection failed with error: \(error)")
            
        default:
            ()
        }
    }

    private func setupDocumentReceipt() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            if let error = error {
                self.error(error.debugDescription)
                return
            }
            
            if isComplete {
                self.parseHeader()
                return
            }
            
            if let data = data {
                self.buffer.append(data)
                self.setupDocumentReceipt()
            } else {
                self.error("No data received")
            }
        }
    }

    private func parseHeader() {
        guard let statusCode = String(data: buffer.prefix(2), encoding: .ascii) else {
            error("Couldn't read status code")
            return
        }

        let metaBytes = buffer.suffix(from: 3).prefix(while: { byte in byte != 0x0d } )
        guard let meta = String(data: metaBytes, encoding: .ascii) else {
            error("Couldn't read meta text")
            return
        }
        
        switch statusCode {
        case "10":
            complete(.input(meta))
            return
        
        case "20":
            break
        
        case "30":
            if let url = URL(string: meta) {
                complete(.redirect(url: GeminiURL(url: url.standardized)))
            } else {
                error("Redirected to mangled URL")
            }

        case "31":
            if let url = URL(string: meta) {
                complete(.redirect(url: GeminiURL(url: url.standardized)))
            } else {
                error("Redirected to mangled URL")
            }
            return
            
        case "40":
            self.error("40 TEMPORARY FAILURE\n\(meta)")
            return
        
        case "41":
            self.error("\(meta) (41 SERVER UNAVAILABLE)")
            return
            
        case "42":
            self.error("\(meta) (42 CGI ERROR)")
            return
        
        case "50":
            error("\(meta) (50 PERMANENT FAILURE)")
            return
            
        case "51":
            error("\(meta) (51 NOT FOUND)")
            return
            
        case "53":
            self.error("\(meta) (53 PROXY REQUEST REFUSED)")
            return
            
        case "59":
            self.error("\(meta) (59 BAD REQUEST)")
            return

        default:
            self.error("Invalid status code \(statusCode)")
            return
        }

        var charset: String.Encoding = .utf8
        var mimeTypeString: String = "text/gemini"
        
        let metaComponents = meta.components(separatedBy: ";").map({ $0.trimmingCharacters(in: .whitespaces).lowercased() })
        
        for component in metaComponents {
            if component.isEmpty {
                continue
            }

            if component.hasPrefix("charset=") {
                let charsetText = component.dropFirst(8)

                switch charsetText {
                case "utf-8":
                    charset = .utf8
                case "iso-8859-1":
                    charset = .isoLatin1
                case "us-ascii":
                    charset = .ascii
                default:
                    error("Unknown charset \(charsetText)")
                    return
                }
            } else if component.contains("=") {
                // Ignore unknown parameter
                ()
            } else {
                mimeTypeString = component
            }
        }
        
        let mimeType: MimeType
        
        switch mimeTypeString {
        case "text/plain":
            mimeType = .text(charset: charset, format: .plain)
        case "text/gemini":
            mimeType = .text(charset: charset, format: .gemini)
        case "image/png", "image/jpeg":
            mimeType = .image
        default:
            error("Unknown MIME type \(mimeTypeString)")
            return
        }

        guard let firstIndex = buffer.firstIndex(of: 0x0a) else {
            error("Header not concluded with line feed")
            return
        }
        
        let documentBytes = buffer.suffix(from: firstIndex + 1)
        
        complete(.success(documentBytes: documentBytes, mimeType: mimeType))
    }

    private func complete(_ result: ConnectionResult) {
        DispatchQueue.main.async {
            if let callback = self.completionHandler {
                callback(result)
            }
        }
    }
    
    private func error(_ error: String) {
        complete(.error("Counldn't retrieve \(url.toString()): \(error)"))
    }
}

enum ConnectionResult {
    case input(String)
    case success(documentBytes: Data, mimeType: MimeType)
    case redirect(url: GeminiURL)
    case error(String)
}

enum MimeType {
    case text(charset: String.Encoding, format: TextFormat)
    case image
}

enum TextFormat {
    case plain
    case gemini
}

struct GeminiURL {
    let scheme: String
    let port: UInt16
    let host: String
    let path: String
    let query: String?
    
    init() {
        scheme = "gemini"
        port = 1965
        host = "gemini.circumlunar.space"
        path = "/"
        query = nil
    }
    
    init(scheme: String, port: UInt16, host: String, path: String, query: String?) {
        self.scheme = scheme
        self.port = port
        self.host = host
        self.path = path
        self.query = query
    }

    init(url: URL) {
        if let scheme = url.scheme {
            self.scheme = scheme
        } else {
            self.scheme = "gemini"
        }
        
        if let port = url.port {
            self.port = UInt16(port)
        } else {
            self.port = 1965
        }
        
        if let host = url.host {
            self.host = host
        } else {
            self.host = "gemini.circumlunar.space"
        }
        
        var path = url.path
        
        // The URL class strips the final slash when the path is non-empty, but we want it.
        if url.path == "/" {
            path = "/"
        } else if url.absoluteString.last == "/" {
            path += "/"
        }

        if path.first != "/" {
            path = "/" + path
        }
        
        self.path = path
        
        if let query = url.query {
            self.query = query
        } else {
            self.query = nil
        }
    }
    
    func combiningRelative(url: URL) -> GeminiURL {
        var path: String
        var urlPath = url.path
        
        // The URL class strips the final slash when the path is non-empty, but we want it.
        if url.path == "/" {
            urlPath = "/"
        } else if url.absoluteString.last == "/" {
            urlPath += "/"
        }
        
        if urlPath.first == "/" {
            path = urlPath
        } else if self.path.last == "/" {
            path = self.path + urlPath
        } else {
            path = self.path
            
            while let char = path.popLast() {
                if char == "/" {
                    path += "/"
                    break
                }
            }
            
            path += urlPath
        }

        return GeminiURL(scheme: self.scheme, port: self.port, host: self.host, path: path, query: url.query)
    }
    
    func appendingQuery(_ query: String) -> GeminiURL {
        return GeminiURL(scheme: self.scheme, port: self.port, host: self.host, path: self.path, query: query)
    }
    
    func toString() -> String {
        var portString: String
        
        if port == 1965 {
            portString = ""
        } else {
            portString = ":\(port)"
        }

        var queryString: String
        
        if let query = self.query {
            queryString = "?\(query)"
        } else {
            queryString = ""
        }
        
        return "\(scheme)://\(host)\(portString)\(path)\(queryString)"
    }
}
