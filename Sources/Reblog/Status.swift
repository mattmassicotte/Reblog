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
	}
}
