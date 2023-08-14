//
//  NetworkLogger.swift
//  DiaBetter
//
//  Created by Владислав Баранкевич on 11.08.2023.
//

import Foundation

struct NetworkLogger {
	
	enum LogLevel {
		case info
		case warning
		case error
		
		fileprivate var prefix: String {
			switch self {
			case .info:    return "ℹ️ INFO"
			case .warning: return "⚠️ WARN"
			case .error:   return "❌ ALERT"
			}
		}
	}
	
	struct Context {
		let file: String
		let function: String
		let line: Int
		var description: String {
			return "\((file as NSString).lastPathComponent): \(line) \(function)"
		}
	}
	
	//MARK: - Properties
	private static let newLine = "\n"
	private static let divider = "---------------------------"
	
	//MARK: - Methods
	static func log(_ request: URLRequest) {
		let method = "--method " + "\(request.httpMethod ?? HTTPMethods.get.rawValue) \(newLine)"
		let url: String = "--url " + "\'\(request.url?.absoluteString ?? "")\' \(newLine)"
		
		var toPrint = newLine + "REQUEST" + newLine + divider + newLine
		var header = ""
		var data: String = ""
		
		if let httpHeaders = request.allHTTPHeaderFields,
		   !httpHeaders.keys.isEmpty {
			
			for (key,value) in httpHeaders {
				header += "--header " + "\'\(key): \(value)\' \(newLine)"
			}
		}
		
		if let bodyData = request.httpBody {
			let bodyBytes = ByteCountFormatter().string(
				fromByteCount: Int64(bodyData.count)
			)
			
			let bodyString = bodyData.prettyPrintedJSONString ?? bodyBytes
			data = "--data '\(bodyString)'"
		}
		
		toPrint += method + url + header + data + divider + newLine
		print(toPrint)
	}
	
	static func log(_ output: URLSession.DataTaskPublisher.Output) {
		let url: String = "--url " + "\'\(output.response.url?.absoluteString ?? "")\' \(newLine)"
		
		var toPrint = newLine + "RESPONSE" + newLine + divider + newLine
		var header: String = ""
		var statusCode: String = ""
		var data: String = "--data "
		
		if let response = output.response as? HTTPURLResponse {
			statusCode = "--status code " + "\(response.statusCode)" + newLine
			let httpHeaders = response.allHeaderFields
			
			if !httpHeaders.keys.isEmpty {
				for (key,value) in httpHeaders {
					header += "--header " + "\'\(key): \(value)\' \(newLine)"
				}
			}
		}
		
		let bodyBytes = ByteCountFormatter().string(
			fromByteCount: Int64(output.data.count)
		)
		
		data += output.data.prettyPrintedJSONString ?? bodyBytes
		
		toPrint += url + statusCode + header + data + newLine + divider + newLine
		print(toPrint)
	}
	
	//MARK: - Warning, Info, Error print methods
	static func info(_ str: String,
					 shouldLogContext: Bool = true,
					 file: String = #file,
					 function: String = #function,
					 line: Int = #line) {
		let context = Context(file: file, function: function, line: line)
		NetworkLogger.handleLog(level: .info,
						 str: str.description,
						 shouldLogContext: shouldLogContext,
						 context: context)
	}
	
	static func warning(_ str: String,
						shouldLogContext: Bool = true,
						file: String = #file,
						function: String = #function,
						line: Int = #line) {
		let context = Context(file: file, function: function, line: line)
		NetworkLogger.handleLog(level: .warning,
						 str: str.description,
						 shouldLogContext: shouldLogContext,
						 context: context)
	}
	
	static func error(_ str: String,
					  shouldLogContext: Bool = true,
					  file: String = #file,
					  function: String = #function,
					  line: Int = #line) {
		let context = Context(file: file, function: function, line: line)
		NetworkLogger.handleLog(level: .error,
						 str: str.description,
						 shouldLogContext: shouldLogContext,
						 context: context)
	}
	
	//MARK: - Fileprivate methods
	fileprivate static func handleLog(level: LogLevel,
									  str: String,
									  shouldLogContext: Bool,
									  context: Context) {
		let logComponents = ["[\(level.prefix)]", str]
		var fullString = logComponents.joined(separator: " ")
		if shouldLogContext {
			fullString += " ➜ \(context.description)"
		}
		
#if DEBUG
		print(fullString)
#endif
	}
}
