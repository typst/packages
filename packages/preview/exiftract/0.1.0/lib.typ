// exiftract — read Exif metadata from images.
//
// This entrypoint exists to define the package's public surface: `read-exif`
// is the only name it exports. The implementation lives in `read.typ` and
// `interpret.typ`.

#import "read.typ": read-exif
