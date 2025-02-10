import Foundation

public struct Account: Decodable, Hashable, Sendable, Identifiable {
	public struct Field: Decodable, Hashable, Sendable {
		public let name: String
		public let value: HTMLContent
		public let verifiedAt: Date?
		
		enum CodingKeys: String, CodingKey {
			case name
			case value
			case verifiedAt = "verified_at"
		}
	}
	
	public let id: String
	public let displayName: String
	public let username: String
	public let fullUsername: String
	public let avatar: String
	public let avatarStatic: String
	
	public let fields: [Field]
	
	enum CodingKeys: String, CodingKey {
		case id
		case displayName = "display_name"
		case fullUsername = "acct"
		case username
		case fields
		case avatar
		case avatarStatic = "avatar_static"
	}
}

extension Account {
	public func resolvedUsername(with local: String) -> String {
		if username == fullUsername {
			return "\(username)@\(local)"
		}
		
		return fullUsername
	}
}
