import Foundation
import Testing

import Reblog

struct ContentParserTests {
	@Test func mentionLink() throws {
		let input = """
 <p><span class="h-card" translate="no"><a href="https://mastodon.social/@person" class="u-url mention">@<span>person</span></a></span> hello</p>
 """
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.link(URL(string: "https://mastodon.social/@person")!, "@person"),
			.text(" hello"),
			.text("\n"),
		]
		
		#expect(output == expected)
	}
}
