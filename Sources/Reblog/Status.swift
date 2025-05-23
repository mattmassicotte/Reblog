import Foundation

public struct Status: Decodable, Hashable, Sendable, Identifiable {
	public let id: String
	public let uri: String
	public let createdAt: Date
	public let content: HTMLContent
	public let account: Account
	public let language: String?
	public let reblogs: Int
	public let favorites: Int
	public let reblog: ReblogStatus?
	public let mediaAttachments: [MediaAttachment]
	public let inReplyToId: String?
	public let favorited: Bool?
	public let reblogged: Bool?
	
	enum CodingKeys: String, CodingKey {
		case id
		case uri
		case createdAt = "created_at"
		case content
		case account
		case language
		case reblogs = "reblogs_count"
		case favorites = "favourites_count"
		case reblog
		case mediaAttachments = "media_attachments"
		case inReplyToId = "in_reply_to_id"
		case favorited = "favourited"
		case reblogged
	}
}

extension Status {
	public var plainStringContent: String {
		get throws {
			let parser = ContentParser()
			
			let components = try parser.parse(content)
			
			return parser.renderToString(components)
		}
	}
}
