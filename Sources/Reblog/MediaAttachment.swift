import Foundation

public struct MediaAttachment: Decodable, Hashable, Sendable, Identifiable {
	public enum MediaType: String, Decodable, Hashable, Sendable {
		case unknown
		case image
		case gifv
		case video
		case audio
	}
	
	public struct Meta: Decodable, Hashable, Sendable {
		
	}
	
	public let id: String
	public let type: MediaType
	public let urlString: String
	public let previewURLString: String?
	public let remoteURLString: String?
	public let meta: Meta
	public let description: String?
	public let blurhash: String
	
	enum CodingKeys: String, CodingKey {
		case id
		case type
		case urlString = "url"
		case previewURLString = "preview_url"
		case remoteURLString = "remote_url"
		case meta
		case description
		case blurhash
	}
	
	public var url: URL? {
		URL(string: urlString)
	}
	
	public var previewURL: URL? {
		previewURLString.flatMap { URL(string: $0) }
	}
}
