
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.0.0"
    exit 1
fi

for cmd in rg sd; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

VERSION="$1"

if ! echo "$VERSION" | rg "^[0-9]+\.[0-9]+\.[0-9]+$" >/dev/null 2>&1; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

echo "The following changes are to be made:"
echo ""
rg "" "typst.toml" -l
rg "version = \"[0-9]\.[0-9]\.[0-9]\"" "typst.toml" -r "version = \"$VERSION\""
echo ""
rg "@(local|preview)/basalt-lib:[0-9]\.[0-9]\.[0-9]" -g "!release.sh" -r "@preview/basalt-lib:$VERSION"
echo ""

printf "Proceed with changes? (y/N)"
read answer
case "$answer" in
    [Yy]*)
        ;;
    *)
        echo "Operation cancelled"
        exit 1
        ;;
esac

sd "version = \"[0-9]\.[0-9]\.[0-9]\"" "version = \"$VERSION\"" "typst.toml"
sd "@(local|preview)/basalt-lib:[0-9]\.[0-9]\.[0-9]" "@preview/basalt-lib:$VERSION" $(rg "@(local|preview)/basalt-lib:[0-9]\.[0-9]\.[0-9]" -g "!release.sh" -l)

echo "Updated version to $VERSION"
