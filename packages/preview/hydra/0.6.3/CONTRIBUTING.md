# Contribution
## Bug fixes
If you want to fix an issue please leave a comment there so others know you are
working on it. If you want to fix a bug which doesn't have an issue yet, please
create an issue first. Exceptions are typos or minor corrections, just opening a
PR for those is fine.

## Features
When adding a new feature, make sure you add tests and documentation for it. You
can open a draft PR without tests and documentation but it will only be merged
once documentation and tests are added.

## Testing
To ensure that your changes don't break exisiting code test it using [Tytanic].
This is done automatically on pull requests, so you do not need to install
Tytanic, but it's nontheless recommended for faster iteration. In general,
running `tt run` will be enough to ensure your changes are correct.

## Manual and examples
The manual contains some example images that may need updating, if you want tp
udpate the manual you can simply run `just watch-manual` and the examples are
regenerated once before the watch session is started.

[Tytanic]: https://github.com/tingerrr/tytanic
