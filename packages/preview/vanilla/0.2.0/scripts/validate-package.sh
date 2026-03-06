#!/usr/bin/env bash

echo "🔍 Validating vanilla Typst package..."
echo ""

errors=0
warnings=0

# Check if typst.toml exists
if [ ! -f "typst.toml" ]; then
  echo "❌ Error: typst.toml not found"
  ((errors++))
else
  echo "✅ typst.toml found"
  
  # Extract version from typst.toml - using a macOS compatible approach
  VERSION=$(grep 'version' typst.toml | sed -E 's/version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "❌ Error: Could not extract version from typst.toml"
    ((errors++))
  else
    echo "✅ Package version: $VERSION"
  fi
  
  # Check for required fields in typst.toml
  for field in name entrypoint authors license description; do
    if ! grep -q "$field" typst.toml; then
      echo "❌ Error: Missing required field '$field' in typst.toml"
      ((errors++))
    fi
  done
  
  # Check for template section
  if ! grep -q "\[template\]" typst.toml; then
    echo "❌ Error: Missing [template] section in typst.toml"
    ((errors++))
  else
    # Check for required template fields
    for field in path entrypoint thumbnail; do
      if ! grep -q "$field" typst.toml; then
        echo "❌ Error: Missing required template field '$field' in typst.toml"
        ((errors++))
      fi
    done
  fi
fi

# Check if README.md exists and is not empty
if [ ! -f "README.md" ]; then
  echo "❌ Error: README.md is missing"
  ((errors++))
elif [ ! -s "README.md" ]; then
  echo "❌ Error: README.md is empty"
  ((errors++))
else
  echo "✅ README.md found"
  
  # Check if README contains examples with @preview import
  if ! grep -q "@preview/vanilla" README.md; then
    echo "⚠️ Warning: README.md should include examples using @preview/vanilla imports"
    ((warnings++))
  fi
fi

# Check if LICENSE exists
if [ ! -f "LICENSE" ]; then
  echo "❌ Error: LICENSE file is missing"
  ((errors++))
else
  echo "✅ LICENSE found"
fi

# Check if src/lib.typ exists
if [ ! -f "src/lib.typ" ]; then
  echo "❌ Error: src/lib.typ is missing"
  ((errors++))
else 
  echo "✅ src/lib.typ found"
fi

# Check if template files exist
if [ ! -d "template" ]; then
  echo "❌ Error: template directory is missing"
  ((errors++))
elif [ ! -f "template/main.typ" ]; then
  echo "❌ Error: template/main.typ is missing"
  ((errors++))
else
  echo "✅ template/main.typ found"
fi

# Check if thumbnail.png exists
if [ ! -f "thumbnail.png" ]; then
  echo "❌ Error: thumbnail.png is missing"
  ((errors++))
else
  echo "✅ thumbnail.png found"
  
  # Check thumbnail size using platform-independent approach
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    THUMBNAIL_SIZE=$(stat -f%z "thumbnail.png")
  else
    # Linux and others
    THUMBNAIL_SIZE=$(stat -c%s "thumbnail.png")
  fi
  
  if [ "$THUMBNAIL_SIZE" -gt 3000000 ]; then
    echo "⚠️ Warning: thumbnail.png exceeds 3MB limit (is $THUMBNAIL_SIZE bytes)"
    ((warnings++))
  fi
fi

echo ""
if [ $errors -gt 0 ]; then
  echo "❌ Validation found $errors errors and $warnings warnings."
  echo "Please fix the errors before creating a release."
  exit 1
elif [ $warnings -gt 0 ]; then
  echo "⚠️ Validation complete with $warnings warnings."
  echo "You may proceed, but consider fixing the warnings."
else
  echo "✅ All files validated successfully!"
fi

echo ""
echo "To create a release tag, run:"
echo "git tag v$VERSION"
echo "git push origin v$VERSION"
echo ""
echo "This will trigger the GitHub Action to submit a PR to the typst/packages repository."
