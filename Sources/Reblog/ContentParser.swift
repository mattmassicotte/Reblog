import Foundation
#if os(Linux)
import FoundationXML
#endif

public typealias HTMLContent = String

public enum HTMLComponent: Hashable, Sendable {
	case text(String)
	case seperator
	case link(URL, String)
	
	public var string: String {
		switch self {
		case let .link(_, text):
			text
		case .seperator:
			"\n\n"
		case let .text(text):
			text
		}
	}
}

class ParserDelegate: NSObject, XMLParserDelegate {
	public var elementHandler: ((HTMLComponent) -> Void)?
	private var activeComponent: HTMLComponent? = nil
	
	@discardableResult
	func commitActive() -> Bool {
		guard let activeComponent else { return false }
		
		elementHandler?(activeComponent)
		
		self.activeComponent = nil
		
		return true
	}
	
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		switch elementName {
		case "p":
			// insert a seperator only if there's an already-active element
			if commitActive() {
				elementHandler?(.seperator)
			}
		case "br":
			commitActive()
			
			elementHandler?(.seperator)
		case "a":
			commitActive()
			
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
		switch elementName {
		case "a":
			// this needs to close and commit the current link
			commitActive()
		default:
			break
		}
	}
	
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		switch activeComponent {
		case let .link(url, text):
			self.activeComponent = .link(url, text + string)
		case let .text(value):
			self.activeComponent = .text(value + string)
		default:
			// begin buffering here
			self.activeComponent = .text(string)
		}
	}
	
	func parserDidEndDocument(_ parser: XMLParser) {
		commitActive()
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
		let transform = "Any-Hex" as NSString
		let convertedString = string.mutableCopy() as! NSMutableString
		
		guard CFStringTransform(convertedString, nil, transform, true) else {
			throw ContentParserError.transformFailed
		}
		
		let pass1 = convertedString as String
		
		return unescapeHTMLEntities(pass1)
#endif
	}
	
	private func fallbackUnescape(_ string: String) -> String {
		let pass1 = string
			.replacingOccurrences(of: "\\u003c", with: "<")
			.replacingOccurrences(of: "\\u003e", with: ">")
		
		return unescapeHTMLEntities(pass1)
	}
	
	private func unescapeHTMLEntities(_ string: String) -> String {
		string
			.replacingOccurrences(of: "&nbsp;", with: " ")
	}
	
	private func convertToXML(_ string: String) -> String {
		// this is just straight garbage
		let newString = string
			.replacingOccurrences(of: "<br>", with: "<br />")
		
		return "<status>" + newString + "</status>"
	}
	
	public func parse(_ string: String) throws -> [HTMLComponent] {
		let unescapedString = try unescape(string)
		let xmlString = convertToXML(unescapedString)
		
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
		var output = ""
		
		for component in components {
			output += component.string
		}
		
		return output
	}
}
