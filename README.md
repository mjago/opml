# OPML Parser

Hierarchical OPML Parser. Unlimited depth of structure is preserved in an object tree of `Outlines`.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  opml:
    github: mjago/opml
```

## Usage

```crystal
require "opml"

outlines = [] of Outline
%w[miscellaneous.opml other.opml].each do |file|
  outlines += Opml.parse_file("opml/" + file)
end
```
See specs for further details.

## Contributing

1. Fork it ( https://github.com/mjago/opml/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mjago](https://github.com/mjago) mjago - creator, maintainer
