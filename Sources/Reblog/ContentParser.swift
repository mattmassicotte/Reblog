import Foundation
#if os(Linux)
import FoundationXML
#endif

class ParserDelegate: NSObject, XMLParserDelegate {
	public var elementHandler: ((HTMLComponent) -> Void)?
	private var activeComponent: HTMLComponent? = nil
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		switch (activeComponent, elementName) {
		case (nil, "a"):
			let url = attributeDict["href"].flatMap { URL(string: $0) }
			guard let url else {
				self.activeComponent = .text("")
				return
			}
			
			self.activeComponent = .link(url, "")
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		switch (activeComponent, elementName) {
		case let (.link(url, text), "a"):
			self.activeComponent = nil
			
			elementHandler?(.link(url, text))
		case let (.text(string), "p"), let (.text(string), "br"):
			elementHandler?(.text(string))
			elementHandler?(.text("\n"))
			self.activeComponent = nil
		case (nil, "p"):
			elementHandler?(.text("\n"))
		case (nil, "br"):
			elementHandler?(.text("\n"))
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		switch activeComponent {
		case let .link(url, text):
			self.activeComponent = .link(url, text + string)
		default:
			elementHandler?(.text(string))
		}
	}
}

public typealias HTMLContent = String

public enum HTMLComponent: Hashable, Sendable {
	case text(String)
	case link(URL, String)
	
	public var string: String {
		switch self {
		case let .link(_, text):
			text
		case let .text(text):
			text
		}
	}
}

enum ContentParserError: Error {
	case transformFailed
}

public struct ContentParser {
	public init() {
	}
	
	private func unescape(_ string: String) throws -> String {
#if os(Linux)
		return fallbackUnescape(string)
#else
		let transform = "Any-Hex/Java"
		let convertedString = string.mutableCopy() as! NSMutableString
		
		guard CFStringTransform(convertedString, nil, transform as NSString, true) else {
			throw ContentParserError.transformFailed
		}
		
		return convertedString as String
#endif
	}
	
	private func fallbackUnescape(_ string: String) -> String {
		string
			.replacingOccurrences(of: "\\u003c", with: "<")
			.replacingOccurrences(of: "\\u003e", with: ">")
	}
	
	private func convertToXML(_ string: String) -> String {
		// this is just straight garbage
		let newString = string
			.replacingOccurrences(of: "<br>", with: "<br />")
		
		return "<status>" + newString + "</status>"
	}
	
	public func parse(_ string: String) throws -> [HTMLComponent] {
		let unscapedString = try unescape(string)
		let xmlString = convertToXML(unscapedString)
		
		let delegate = ParserDelegate()
		let parser = XMLParser(data: Data(xmlString.utf8))
		
		parser.delegate = delegate
		
		var components = [HTMLComponent]()
		
		delegate.elementHandler = { components.append($0) }
		
		parser.parse()
		
		if let error = parser.parserError {
			throw error
		}
		
		return components
	}
	
	public func renderToString(_ components: [HTMLComponent]) -> String {
		components.reduce("", { $0 + $1.string })
	}
}
