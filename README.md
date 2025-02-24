<div align="center">

[![Build Status][build status badge]][build status]
[![Matrix][matrix badge]][matrix]

</div>

# Reblog
Little library for working with the Mastodon API

Contains some very simple types for decoding and processing statuses.

If you are looking for something full-featured, please check out [TootSDK](https://github.com/TootSDK/TootSDK).

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/Reblog", branch: "main")
]
```

## Usage

```swift
import Reblog

// data from call to "/api/v1/timelines/home"
let data = "..."

let statuses = JSONDecoder().decode([Status].self, from: data)
```

## Contributing and Collaboration

I would love to hear from you! Issues or pull requests work great. Both a [Matrix space][matrix] and [Discord][discord] are available for live help, but I have a strong bias towards answering in the form of documentation. You can also find me on [the web](https://www.massicotte.org).

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/Reblog/actions
[build status badge]: https://github.com/mattmassicotte/Reblog/workflows/CI/badge.svg
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
[discord]: https://discord.gg/esFpX6sErJ
