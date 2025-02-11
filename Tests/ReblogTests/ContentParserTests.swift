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
	
	@Test func escapedSignificantCharacters() throws {
		let input = """
\\u003ca href="https://mastodon.social/@person" class="u-url mention">@person\\u003c/a>
"""
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.link(URL(string: "https://mastodon.social/@person")!, "@person"),
		]
		
		#expect(output == expected)
	}
	
	@Test func twoConsectivePs() throws {
		let input = """
<p>one</p><p>two</p>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.text("one"),
			.text("\n"),
			.text("two"),
			.text("\n"),
		]
		
		#expect(output == expected)

	}
}

extension ContentParserTests {
	@Test func renderToPlainString() throws {
		let input = """
<p><span class="h-card" translate="no"><a href="https://mastodon.social/@person" class="u-url mention">@<span>person</span></a></span> hello</p>
"""
		
		let output = try ContentParser().parse(input)
		let string = ContentParser().renderToString(output)
		
		#expect(string == "@person hello\n")
	}
}
