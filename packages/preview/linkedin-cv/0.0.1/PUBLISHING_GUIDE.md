# Guide to Publishing `linkedin-cv` as a Typst Package

This guide provides detailed steps to publish this repository as a package in the Typst Universe.

## Prerequisites

- A GitHub account
- Git installed on your machine
- Access to the Typst Packages repository

## Step 1: Review and Fix the Package Manifest

### 1.1 Update `typst.toml`

Before publishing, ensure your `typst.toml` file is correct and complete:

**Current Issues to Fix:**
- ❌ **Repository URL is incorrect**: Currently points to `https://github.com/ChHecker/unify` but should point to this repository
- ⚠️ **Exclude field**: Currently excludes `["examples"]` but your directory is `example` (singular)

**Required Fields (based on [Typst manifest docs](https://github.com/typst/packages/blob/main/docs/manifest.md)):**
- ✅ `name` - Must be lowercase with hyphens (currently `"linkedin-cv"` - correct)
- ✅ `version` - Semantic version (currently `"0.0.1"` - correct)
- ✅ `entrypoint` - Main file (currently `"lib.typ"` - correct)
- ✅ `authors` - List of authors (currently set)
- ✅ `license` - Must be SPDX identifier (currently `"MIT"` - correct)
- ✅ `description` - Brief description (currently set)
- ✅ `repository` - **NEEDS UPDATE** to point to the correct GitHub repository

**Optional but Recommended:**
- ✅ `keywords` - Already set
- ✅ `categories` - Already set (should be one of: "template", "library", or "text")
- ✅ `disciplines` - Already set (good for discoverability)
- ✅ `exclude` - Should exclude build artifacts and example files

**Action Items:**
1. Update the `repository` field to point to your actual GitHub repository URL
2. Update `exclude` to: `["build", "example"]` or `["build", "example/**"]`
3. Consider adding a `thumbnail` field (optional) pointing to a preview image
4. Verify `categories` - should be `["template"]` since this is a CV template, not just `["text"]`

### 1.2 Verify Package Structure

Ensure your package structure is correct:
- ✅ `lib.typ` exists and is the entrypoint
- ✅ All dependencies (files in `src/`) are properly imported in `lib.typ`
- ✅ No broken imports or missing files

## Step 2: Prepare Repository

### 2.1 Create/Update README.md

Create a comprehensive README.md that includes:
- Package description
- Installation instructions
- Usage examples (reference your `example/cv.typ`)
- API documentation
- License information

**Example README structure:**
```markdown
# LinkedIn CV Template for Typst

A beautiful CV template that emulates the LinkedIn UI.

## Installation

```typ
#import "@preview/linkedin-cv:0.0.1": *
```

## Usage

[Include example code]
```

### 2.2 Ensure License File Exists

Make sure you have a `LICENSE` or `LICENSE.txt` file matching the license specified in `typst.toml` (MIT).

### 2.3 Clean Up Repository

- Ensure `.gitignore` excludes build artifacts (`build/`)
- Consider if `example/` should be in the repository (it's helpful for users, so keep it but exclude it from the package via `exclude` field)

## Step 3: Choose Publishing Method

You have two options:

### Method A: Manual Fork and PR (Recommended for First-Time Publishing)

### Method B: Using `typship` Tool (Faster for Updates)

## Step 4: Publishing Method A - Manual Process

### 4.1 Fork the Typst Packages Repository

1. Navigate to https://github.com/typst/packages
2. Click the "Fork" button in the top-right corner
3. Wait for the fork to complete

### 4.2 Clone Your Forked Repository

```bash
git clone https://github.com/YOUR-USERNAME/packages.git
cd packages
```

### 4.3 Set Up Upstream Remote (Optional but Recommended)

```bash
git remote add upstream https://github.com/typst/packages.git
```

### 4.4 Create Package Directory

```bash
mkdir -p packages/preview/linkedin-cv/0.0.1
```

### 4.5 Copy Package Files

From your `linkedin-cv` project directory, copy all necessary files:

```bash
# From your linkedin-cv project root
cd /path/to/your/linkedin-cv

# Copy package files to the packages repository
cp lib.typ ../packages/packages/preview/linkedin-cv/0.0.1/
cp typst.toml ../packages/packages/preview/linkedin-cv/0.0.1/
cp -r src ../packages/packages/preview/linkedin-cv/0.0.1/

# Note: Do NOT copy build/, example/, or other excluded directories
```

**Files to include:**
- ✅ `lib.typ` (entrypoint)
- ✅ `typst.toml` (manifest)
- ✅ `src/` directory (all source files)
- ❌ `build/` (excluded)
- ❌ `example/` (excluded)
- ❌ `justfile` (build tool, not needed)
- ❌ `.git/` (if any)

### 4.6 Verify Package Structure in Packages Repository

The structure should look like:
```
packages/preview/linkedin-cv/0.0.1/
├── lib.typ
├── typst.toml
└── src/
    ├── colors.typ
    ├── components.typ
    ├── frame.typ
    ├── icon-data.json
    ├── layout.typ
    ├── tech-icons.typ
    ├── timeline-state.typ
    ├── typography.typ
    └── utils.typ
```

### 4.7 Commit Your Changes

```bash
cd ../packages  # Back to packages repository root
git add packages/preview/linkedin-cv/0.0.1
git commit -m "Add linkedin-cv version 0.0.1"
```

### 4.8 Push to Your Fork

```bash
git push origin main
```

### 4.9 Create Pull Request

1. Navigate to https://github.com/typst/packages
2. You should see a banner suggesting to create a PR from your fork
3. Click "Compare & pull request"
4. Fill in the PR details:
   - **Title**: `Add linkedin-cv version 0.0.1`
   - **Description**: Include:
     - Brief description of the package
     - What it does
     - How to use it
     - Any relevant notes
5. Click "Create pull request"

### 4.10 Respond to Review Feedback

- The Typst team will review your PR
- They may request changes
- Address all feedback and update your PR
- Once approved, it will be merged

## Step 5: Publishing Method B - Using `typship` Tool

### 5.1 Install `typship`

```bash
# Install via cargo (if you have Rust installed)
cargo install typship

# Or download from: https://github.com/sjfhsjfh/typship
```

### 5.2 Generate GitHub Personal Access Token

**Important**: The token needs proper permissions to create branches and PRs.

1. Go to GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Click "Generate new token"
3. Configure the token:
   - **Token name**: `typship-publishing` (or any descriptive name)
   - **Expiration**: Choose appropriate expiration (30 days, 90 days, etc.)
   - **Repository access**:
     - **Option A (Recommended)**: Select "All repositories" (if you're comfortable)
     - **Option B**: Select "Only select repositories" and add your forked `packages` repository
   - **Permissions needed**:
     - **Contents**: Read and write (required for creating branches and commits)
     - **Pull requests**: Read and write (required for creating PRs)
     - **Metadata**: Read (automatically selected)
     - **Actions**: Read (optional, but may be needed in some cases)
4. Generate the token and **copy it immediately** (you won't see it again)

### 5.3 Authenticate with `typship`

```bash
typship login universe
# Enter your GitHub username and PAT when prompted
```

### 5.4 Publish Your Package

From your `linkedin-cv` project root directory:

```bash
cd /path/to/your/linkedin-cv
typship publish universe
```

The tool will:
- Validate your `typst.toml`
- Prepare your package files
- Create a PR automatically to the Typst Packages repository

### 5.5 Complete the PR

After `typship` creates the PR:
- Review the PR on GitHub
- Add any additional context to the PR description
- Wait for review and approval

## Step 6: Post-Publication

### 6.1 Test Installation

Once your package is published, test it:

```typ
#import "@preview/linkedin-cv:0.0.1": *

#show: linkedin-cv.with(...)
```

### 6.2 Update Documentation

- Update your repository's README with installation instructions
- Consider adding more examples
- Document all public functions and their parameters

### 6.3 Tag Release in Your Repository

Create a Git tag matching your version:

```bash
git tag -a v0.0.1 -m "Initial release"
git push origin v0.0.1
```

## Checklist Before Publishing

- [ ] `typst.toml` has correct repository URL
- [ ] `typst.toml` excludes build artifacts (`build/`)
- [ ] `typst.toml` excludes example files (`example/`)
- [ ] `lib.typ` entrypoint exists and works
- [ ] All imports in `lib.typ` resolve correctly
- [ ] LICENSE file exists in repository
- [ ] README.md exists and is informative
- [ ] Package has been tested locally
- [ ] Package name follows Typst conventions (lowercase, hyphens)
- [ ] Version number follows semantic versioning
- [ ] All required manifest fields are present

## Important Notes

1. **Package Name**: Must be lowercase with hyphens. Cannot be changed after first publication.
2. **Versioning**: Use semantic versioning (major.minor.patch). Once published, a version cannot be modified.
3. **Exclude Patterns**: Files/directories listed in `exclude` won't be included in the published package.
4. **Entrypoint**: The `lib.typ` file should export the main function that users will call.
5. **Review Process**: The Typst team reviews all packages. Be patient and responsive to feedback.

## Troubleshooting

### Common Issues

1. **"Resource not accessible by personal access token" errors**:
   - **Error creating branch**: PAT needs **Contents: Read and write** permission
   - **Error creating pull request**: PAT needs **Pull requests: Read and write** permission
   - **Fix**: Generate a new fine-grained PAT with ALL of these permissions:
     - Repository access set to "All repositories" (recommended) or explicitly include your forked `packages` repo
     - **Contents: Read and write** (required for creating branches and commits)
     - **Pull requests: Read and write** (required for creating PRs)
     - **Metadata: Read** (automatically selected)
   - After creating/updating the token with correct permissions, re-authenticate: `typship login universe`
   - Make sure you're using the correct GitHub username when authenticating
   - **Note**: If you get the branch creation error, then fix it and get the PR error, you may need to ensure BOTH permissions are set together

2. **Manifest validation errors**: Check all required fields are present and valid

3. **Import errors**: Ensure all dependencies are included in the package

4. **Name conflicts**: Your package name must be unique. If taken, choose another.

5. **Version conflicts**: Each version can only be published once

6. **Wrong forked repository name**: Make sure when `typship` asks for your forked repository name, you enter exactly `packages` (not `typst/packages` or a full URL)

### Getting Help

- Typst Packages Repository: https://github.com/typst/packages
- Typst Discord: Check for community support
- Package Manifest Docs: https://github.com/typst/packages/blob/main/docs/manifest.md

## Next Steps After Publication

1. Announce your package in Typst community channels
2. Monitor issues and feedback
3. Plan future versions with bug fixes and features
4. Consider adding more examples or documentation
