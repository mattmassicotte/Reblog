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
		]
		
		#expect(output == expected)
	}
	
	@Test func spanWithinLink() throws {
		let input = """
<a href="https://example.com"><span>hello</span></a>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.link(URL(string: "https://example.com")!, "hello"),
		]
		
		#expect(output == expected)
	}

	@Test func escapedAngleBrackets() throws {
		let input = """
\\u003ca href="https://mastodon.social/@person" class="u-url mention"\\u003e@person\\u003c/a\\u003e
"""
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.link(URL(string: "https://mastodon.social/@person")!, "@person"),
		]
		
		#expect(output == expected)
	}
	
	@Test func twoConsectiveTopLevelElements() throws {
		let input = """
<p>one</p><p>two</p>
"""

		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.text("one"),
			.seperator,
			.text("two"),
		]
		
		#expect(output == expected)
	}
	
	@Test func handleUnterminatedBR() throws {
		let input = """
<p>one<br>two</p>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.text("one"),
			.seperator,
			.text("two"),
		]
		
		#expect(output == expected)
	}
	
	@Test func consecutiveTextElements() throws {
		let input = """
<p>Y’ou’re</p>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.text("Y’ou’re"),
		]
		
		#expect(output == expected)
	}
	
	@Test func spansWithinLinkText() throws {
		let input = """
<p>text <a href="https://example.com">link</a></p>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.text("text "),
			.link(URL(string: "https://example.com")!, "link")
		]
		
		#expect(output == expected)
	}
	
	@Test
	func hashtag() throws {
		let input = """
<a href="https://iosdev.space/tags/HourOfCode" class="mention hashtag" rel="nofollow noopener" target="_blank">#<span>HourOfCode</span></a>
"""
		
		let output = try ContentParser().parse(input)
		let expected: [HTMLComponent] = [
			.link(URL(string: "https://iosdev.space/tags/HourOfCode")!, "#HourOfCode")
		]
		
		#expect(output == expected)
	}
}

extension ContentParserTests {
	@Test func renderLinkAndText() throws {
		let input = """
<p><span class="h-card" translate="no"><a href="https://mastodon.social/@person" class="u-url mention">@<span>person</span></a></span> hello</p>
"""
		
		let output = try ContentParser().parse(input)
		let string = ContentParser().renderToString(output)
		
		#expect(string == "@person hello")
	}
	
	@Test func renderTwoParagraphs() throws {
		let input = """
<p>one</p><p>two</p>
"""
		
		let output = try ContentParser().parse(input)
		let string = ContentParser().renderToString(output)
		
		#expect(string == "one\n\ntwo")
	}
}
