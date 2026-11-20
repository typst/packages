# Files

## Package size

To keep the package small and fast to download, there are two different limits
for the package size. The first one is the size of the bundle and the second
one is for the archive. Exceptions can be made on a case-by-case basis, but
should be well-motivated.

### Bundle

Maximum size: `15 MiB`

The package bundle includes those files that are downloaded when importing a
package. These are all submitted files *without* the ones that are excluded,
thus the required files in the [what to exclude] guide.

### Archive

Maximum size: `30 MiB`

The package archive contains all submitted files *also counting* the ones that
are in the `exclude` list. This corresponds to the required files plus the
documentation files in the [what to exclude] guide. The maximum size for
package archives is double the maximum size of bundles.

[what to exclude]: tips.md#what-to-commit-what-to-exclude
