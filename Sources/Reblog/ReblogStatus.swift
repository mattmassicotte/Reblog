import Foundation

public struct ReblogStatus: Decodable, Hashable, Sendable, Identifiable {
	public let id: String
	public let uri: String
	public let createdAt: Date
	public let content: HTMLContent
	public let account: Account
	public let language: String?
	public let reblogs: Int
	public let favorites: Int
	
	enum CodingKeys: String, CodingKey {
		case id
		case uri
		case createdAt = "created_at"
		case content
		case account
		case language
		case reblogs = "reblogs_count"
		case favorites = "favourites_count"
	}
}
 
extension ReblogStatus {
	public var plainStringContent: String {
		get throws {
			let parser = ContentParser()
			
			let components = try parser.parse(content)
			
			return parser.renderToString(components)
		}
	}
}
