import Foundation

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
		case let (.text(string), "p"):
			elementHandler?(.text(string))
			elementHandler?(.text("\n"))
			self.activeComponent = nil
		case (nil, "p"):
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

public enum HTMLComponent: Hashable, Sendable {
	case text(String)
	case link(URL, String)
}

public struct ContentParser {
	public init() {
	}
	
	public func parse(_ string: String) throws -> [HTMLComponent] {
		let delegate = ParserDelegate()
		let parser = XMLParser(data: Data(string.utf8))
		
		parser.delegate = delegate
		
		var components = [HTMLComponent]()
		
		delegate.elementHandler = { components.append($0) }
		
		parser.parse()
		
		if let error = parser.parserError {
			throw error
		}
		
		return components
	}
}
