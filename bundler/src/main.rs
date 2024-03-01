use std::borrow::Cow;
use std::collections::HashMap;
use std::env::args;
use std::fs;
use std::fs::File;
use std::io;
use std::io::BufReader;
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{bail, Context};
use image::codecs::webp::{WebPEncoder, WebPQuality};
use image::imageops::FilterType;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use semver::Version;
use serde::{Deserialize, Serialize};
use unicode_ident::{is_xid_continue, is_xid_start};
use unscanny::Scanner;

const DIST: &str = "dist";
const THUMBS_DIR_NAME: &str = "thumbnails";

fn main() -> anyhow::Result<()> {
    println!("Starting bundling.");

    let mut next_is_out = false;
    let out_dir = args()
        .skip(1)
        .find(|arg| {
            if next_is_out {
                return true;
            }
            next_is_out = arg == "--out-dir" || arg == "-o";
            false
        })
        .unwrap_or_else(|| DIST.to_string());

    let out_dir = Path::new(&out_dir);
    let mut namespace_errors = vec![];

    for entry in walkdir::WalkDir::new("packages")
        .min_depth(1)
        .max_depth(1)
        .sort_by_file_name()
    {
        let entry = entry?;
        if !entry.metadata()?.is_dir() {
            continue;
        }

        let path = entry.into_path();
        let namespace = path
            .file_name()
            .context("cannot read namespace folder name")?
            .to_str()
            .context("invalid namespace")?;

        println!("Processing namespace: {}", namespace);

        let mut paths = vec![];
        let mut index = vec![];
        let mut package_errors = vec![];
        fs::create_dir_all(Path::new(&out_dir).join(namespace).join(THUMBS_DIR_NAME))?;

        for entry in walkdir::WalkDir::new(&path).min_depth(2).max_depth(2) {
            let entry = entry?;
            if !entry.metadata()?.is_dir() {
                continue;
            }

            let path = entry.into_path();
            match process_package(&path, namespace, out_dir)
                .with_context(|| format!("failed to process package at {}", path.display()))
            {
                Ok(info) => {
                    paths.push(path);
                    index.push(info);
                }
                Err(err) => package_errors.push(err),
            }
        }

        println!("Determining timestamps.");
        determine_timestamps(&paths, &mut index)?;

        // Sort the index.
        index.sort_by_key(|info| (info.base.name.clone(), info.base.version.clone()));

        println!("Writing index.");
        fs::write(
            Path::new(&out_dir).join(namespace).join("index.json"),
            serde_json::to_vec(&index.iter().map(IndexPackageInfo::from).collect::<Vec<_>>())?,
        )?;
        fs::write(
            Path::new(&out_dir).join(namespace).join("index.full.json"),
            serde_json::to_vec(&index)?,
        )?;

        if !package_errors.is_empty() {
            namespace_errors.push((namespace.to_string(), package_errors));
        }
    }

    println!("Done.");

    if !namespace_errors.is_empty() {
        eprintln!("Failed to process some packages:");
        for (namespace, errors) in namespace_errors {
            eprintln!("  Namespace: {}", namespace);
            for error in errors {
                eprintln!("    {:#}", error);
            }
        }

        eprintln!("Failing packages omitted from index.");
        std::process::exit(1);
    }

    Ok(())
}

/// Create an archive for a package.
fn process_package(
    path: &Path,
    namespace: &str,
    out_dir: &Path,
) -> anyhow::Result<ExtendedPackageInfo> {
    println!("Bundling {}.", path.display());
    let manifest = parse_manifest(path, namespace).context("failed to parse package manifest")?;

    let exclude = build_exclude_list(&manifest)?;
    let buf = build_archive(path, &exclude).context("failed to build archive")?;
    let readme = read_readme(path)?;

    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&manifest.package, &buf, namespace, out_dir)
        .context("failed to write archive")?;
    write_thumbnails(path, &manifest, namespace, out_dir).context("failed to write thumbnails")?;

    Ok(ExtendedPackageInfo {
        base: manifest.package,
        template: manifest.template,
        readme,
        size: buf.len(),
        // These will be filled in later.
        updated_at: 0,
        released_at: 0,
    })
}

/// Read and validate the package's manifest.
fn parse_manifest(path: &Path, namespace: &str) -> anyhow::Result<PackageManifest> {
    let src = fs::read_to_string(path.join("typst.toml"))?;

    let manifest: PackageManifest = toml::from_str(&src)?;
    let expected = format!(
        "packages/{}/{}/{}",
        namespace, manifest.package.name, manifest.package.version
    );

    if path != Path::new(&expected) {
        bail!("package directory name and manifest are mismatched");
    }

    if !is_ident(&manifest.package.name) {
        bail!("package name is not a valid identifier");
    }

    for author in &manifest.package.authors {
        check_author_name(author).context("error while checking author name")?;
    }

    let license = spdx::Expression::parse(&manifest.package.license)
        .context("failed to parse SPDX license expression")?;

    for requirement in license.requirements() {
        let id = requirement
            .req
            .license
            .id()
            .context("license must not contain a referencer")?;

        if !id.is_osi_approved() {
            bail!("license is not OSI approved: {}", id.full_name);
        }
    }

    let entrypoint = path.join(&manifest.package.entrypoint);
    check_typst_file(&entrypoint, "entrypoint")?;

    if let Some(template) = &manifest.template {
        for template in &template.start {
            validate_template(path, template)?;
        }
    }

    Ok(manifest)
}

fn validate_template(path: &Path, template: &TemplateStartingPoint) -> anyhow::Result<()> {
    let template_path = path.join(&template.path);
    let entrypoint = template_path.join(&template.entrypoint);
    check_typst_file(&entrypoint, "template entrypoint")?;

    if !is_ident(&template.name) {
        bail!(
            "template name `{}` is not a valid identifier",
            template.name
        );
    }

    let thumbnail = template_path.join(&template.thumbnail);

    // Check that the thumbnail is smaller than 3MB.
    let metadata = fs::metadata(&thumbnail).context("failed to read thumbnail metadata")?;
    if metadata.len() > 3 * 1024 * 1024 {
        bail!("thumbnail must be smaller than 3MB");
    }

    let thumbnail_read =
        BufReader::new(File::open(&thumbnail).context("failed to open thumbnail")?);

    // The thumbnail must be a valid PNG or WebP image file. Its longest edge
    // shall be at least 1080px long.

    let extension = thumbnail
        .extension()
        .context("thumbnail has no extension")?
        .to_ascii_lowercase();

    if extension != "png" && extension != "webp" {
        bail!("thumbnail must be a PNG or WebP image");
    }

    let image = image::load(
        thumbnail_read,
        if extension == "png" {
            image::ImageFormat::Png
        } else {
            image::ImageFormat::WebP
        },
    )?;
    let longest_edge = image.width().max(image.height());

    if longest_edge < 1080 {
        bail!("each thumbnail's longest edge must be at least 1080px long");
    }

    Ok(())
}

// Check that a Typst file exists, its name ends in `.typ`, and it is valid
// UTF-8.
fn check_typst_file(path: &Path, name: &str) -> anyhow::Result<()> {
    if !path.exists() {
        bail!("{} is missing", name);
    }

    if path.extension().map_or(true, |ext| ext != "typ") {
        bail!("{} must have a .typ extension", name);
    }

    fs::read_to_string(path).context("failed to read Typst file")?;
    Ok(())
}

fn build_exclude_list(manifest: &PackageManifest) -> anyhow::Result<Cow<[String]>> {
    match &manifest.template {
        Some(t) if !t.start.is_empty() => {
            let mut exclude = manifest.package.exclude.clone();
            for template in &t.start {
                exclude.push(
                    Path::new(&template.path)
                        .join(&template.thumbnail)
                        .to_str()
                        .context("Thumbnail path is not valid UTF-8")?
                        .to_owned(),
                )
            }

            Ok(Cow::Owned(exclude))
        }
        _ => Ok(Cow::Borrowed(&manifest.package.exclude)),
    }
}

/// Return the README file as a string.
fn read_readme(dir_path: &Path) -> anyhow::Result<String> {
    fs::read_to_string(dir_path.join("README.md")).context("failed to read README.md")
}

/// Build a comrpessed archive for a directory.
fn build_archive(dir_path: &Path, exclude: &[String]) -> anyhow::Result<Vec<u8>> {
    let mut buf = vec![];
    let compressed = flate2::write::GzEncoder::new(&mut buf, flate2::Compression::default());
    let mut builder = tar::Builder::new(compressed);

    let mut overrides = ignore::overrides::OverrideBuilder::new(dir_path);
    for exclusion in exclude {
        if exclusion.starts_with('!') {
            bail!("globs with '!' are not supported");
        }
        let exclusion = exclusion.trim_start_matches("./");
        overrides.add(&format!("!{exclusion}"))?;
    }

    for entry in ignore::WalkBuilder::new(dir_path)
        .overrides(overrides.build()?)
        .sort_by_file_name(|a, b| a.cmp(b))
        .build()
    {
        let entry = entry?;
        let file_path = entry.path();
        let mut local_path = file_path.strip_prefix(dir_path)?;
        if local_path.as_os_str().is_empty() {
            local_path = Path::new(".");
        }
        println!("  Adding {}", local_path.display());
        builder.append_path_with_name(file_path, local_path)?;
    }

    builder.finish()?;
    drop(builder);
    Ok(buf)
}

/// Ensures that the archive can be decompressed and read.
fn validate_archive(buf: &[u8]) -> anyhow::Result<()> {
    let decompressed = flate2::read::GzDecoder::new(io::Cursor::new(&buf));
    let mut tar = tar::Archive::new(decompressed);
    for entry in tar.entries()? {
        let _ = entry?;
    }
    Ok(())
}

/// Write a compressed archive to the output directory.
fn write_archive(
    info: &PackageInfo,
    buf: &[u8],
    namespace: &str,
    out_dir: &Path,
) -> anyhow::Result<()> {
    let path = out_dir.join(format!(
        "{}/{}-{}.tar.gz",
        namespace, info.name, info.version
    ));
    fs::write(path, buf)?;
    Ok(())
}

/// Write any thumbnail images to the `dist` directory.
fn write_thumbnails(
    path: &Path,
    manifest: &PackageManifest,
    namespace: &str,
    out_dir: &Path,
) -> anyhow::Result<()> {
    let thumbnail_root = out_dir.join(namespace).join(THUMBS_DIR_NAME);

    for (i, template) in manifest.template.iter().flat_map(|t| &t.start).enumerate() {
        let orig_thumbnail_path = path.join(&template.path).join(&template.thumbnail);

        // Thumbnails that are WebP and already and smaller than 1MB should be
        // copied as-is.
        let was_webp = orig_thumbnail_path
            .extension()
            .map_or(false, |ext| ext.to_ascii_lowercase() == "webp");

        // Get file size.
        let size = fs::metadata(&orig_thumbnail_path)?.len();
        let keep_original = was_webp && size < 1024 * 1024;

        let image = image::open(&orig_thumbnail_path)?;
        // Choose a fast filter for the miniature.
        let miniature = image.resize(400, 400, FilterType::CatmullRom);

        let thumbnail_path = thumbnail_root.join(format!(
            "{}-{}-{}-small.webp",
            manifest.package.name, manifest.package.version, i
        ));

        let mut miniature_buf = Vec::new();

        // A big fight is going on in the Image crate's GitHub: They want to
        // remove the C dependency for WebP encoding but the Rust alternative
        // does not support lossy encoding. Many people are unhappy about this.
        #[allow(deprecated)]
        let miniature_encoder =
            WebPEncoder::new_with_quality(&mut miniature_buf, WebPQuality::lossy(85));

        miniature_encoder.encode(
            miniature.to_rgb8().as_raw(),
            miniature.width(),
            miniature.height(),
            image::ColorType::Rgb8,
        )?;

        fs::write(thumbnail_path, miniature_buf)?;

        let thumbnail_path = thumbnail_root.join(format!(
            "{}-{}-{}.webp",
            manifest.package.name, manifest.package.version, i
        ));

        if keep_original {
            fs::copy(&orig_thumbnail_path, thumbnail_path)?;
            return Ok(());
        }

        // The WebP file was too big if keep_original is false.
        let resize = was_webp || image.width() * image.height() < 3000 * 2000;

        let resized = if resize {
            image.resize(1920, 1920, FilterType::Lanczos3)
        } else {
            image
        };

        let mut buf = Vec::new();
        #[allow(deprecated)]
        let encoder = WebPEncoder::new_with_quality(&mut buf, WebPQuality::lossy(98));
        encoder.encode(
            resized.to_rgb8().as_raw(),
            resized.width(),
            resized.height(),
            image::ColorType::Rgb8,
        )?;

        fs::write(thumbnail_path, buf)?;
    }
    Ok(())
}

/// Determine all packages timestamps.
fn determine_timestamps(
    paths: &[PathBuf],
    index: &mut [ExtendedPackageInfo],
) -> anyhow::Result<()> {
    // Check if git is installed on the system.
    let has_git = Command::new("git").arg("--version").output().is_ok();

    // Determine timestamp via Git. Do this in parallel because it is pretty
    // slow.
    let timestamps = paths
        .par_iter()
        .map(|p| {
            if has_git {
                timestamp_for_path_with_git(p)
            } else {
                timestamp_for_path_with_fs(p)
            }
        })
        .collect::<Result<Vec<_>, _>>()?;

    // Determine the release dates for all packages.
    // It is the minimum update date for any of its versions.
    let mut release_dates: HashMap<String, u64> = HashMap::new();
    for (info, &t) in index.iter().zip(&timestamps) {
        release_dates
            .entry(info.base.name.clone())
            .and_modify(|v| *v = (*v).min(t))
            .or_insert(t);
    }

    // Write update & release dates.
    for (info, &t) in index.iter_mut().zip(&timestamps) {
        info.updated_at = t;
        info.released_at = release_dates[&info.base.name];
    }

    Ok(())
}

/// Call Git and get the Unix timestamp of a commit date.
fn timestamp_for_path_with_git(path: &Path) -> anyhow::Result<u64> {
    // These commits should be ignored (they are moves).
    const SKIP: &[&str] = &["d22a2d5c3e54d7abd7960650221eb08a7f3fc6ad"];

    let mut command = Command::new("git");
    command.args([
        "--no-pager", // Disable interactivity with --no-pager.
        "log",
        "--no-patch",
        "--follow",
        "--format=%H %ct",
    ]);
    command.arg(path.join("typst.toml"));

    // Fails if the Git reports an error or the number could not be parsed.
    let output = command.output()?;
    if !output.status.success() {
        bail!("git failed: {}", std::str::from_utf8(&output.stderr)?);
    }

    std::str::from_utf8(&output.stdout)?
        .lines()
        .map(|line| line.split_whitespace())
        .filter_map(|mut parts| parts.next().zip(parts.next()))
        .find(|(hash, _)| !SKIP.contains(hash))
        .and_then(|(_, ts)| ts.parse::<u64>().ok())
        .context("failed to determine commit timestamp")
}

// Check the timestamp of a file using the filesystem.
fn timestamp_for_path_with_fs(path: &Path) -> anyhow::Result<u64> {
    let metadata = fs::metadata(path.join("typst.toml"))?;
    metadata
        .modified()
        .map(|t| t.duration_since(std::time::UNIX_EPOCH).unwrap().as_secs())
        .context("failed to determine file timestamp")
}

/// A parsed package manifest + extra metadata.
#[derive(Debug, Clone, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
struct ExtendedPackageInfo {
    /// The information from the package manifest.
    #[serde(flatten)]
    base: PackageInfo,
    /// The template metadata
    #[serde(skip_serializing_if = "Option::is_none")]
    template: Option<TemplateInfo>,
    /// The compressed archive size in bytes.
    size: usize,
    /// The unsanitized README markdown.
    readme: String,
    /// Release time of this version of the package.
    updated_at: u64,
    /// Release time of the first version of this package.
    released_at: u64,
}

/// A parsed package manifest with the release time.
#[derive(Debug, Clone, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
struct IndexPackageInfo {
    /// The information from the package manifest.
    #[serde(flatten)]
    package: PackageInfo,
    /// The template metadata
    #[serde(skip_serializing_if = "Option::is_none")]
    template: Option<TemplateInfo>,
    /// Release time of this version of the package.
    updated_at: u64,
}

impl From<&ExtendedPackageInfo> for IndexPackageInfo {
    fn from(info: &ExtendedPackageInfo) -> Self {
        IndexPackageInfo {
            package: info.base.clone(),
            template: info.template.clone(),
            updated_at: info.updated_at,
        }
    }
}

/// A parsed package manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct PackageManifest {
    package: PackageInfo,
    #[serde(skip_serializing_if = "Option::is_none")]
    template: Option<TemplateInfo>,
    #[serde(skip_serializing_if = "Option::is_none")]
    tool: Option<Tool>,
}

/// The `package` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct PackageInfo {
    name: String,
    version: Version,
    entrypoint: String,
    authors: Vec<String>,
    license: String,
    description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    homepage: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    repository: Option<String>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    #[serde(default)]
    keywords: Vec<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    compiler: Option<Version>,
    #[serde(skip_serializing_if = "Vec::is_empty")]
    #[serde(default)]
    exclude: Vec<String>,
}

/// The `template` key in the manifest.
#[derive(Debug, Clone, Default, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct TemplateInfo {
    #[serde(skip_serializing_if = "Vec::is_empty")]
    #[serde(default)]
    start: Vec<TemplateStartingPoint>,
}

/// A starting point for a template.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct TemplateStartingPoint {
    name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    description: Option<String>,
    path: String,
    entrypoint: String,
    thumbnail: String,
}

/// The `tool` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct Tool {}

/// Scan an author name. Author names can contain a name and, in angle brackets,
/// one of a URL, email or GitHub username.
fn check_author_name(name: &str) -> anyhow::Result<()> {
    let mut s = Scanner::new(name);
    s.eat_until(|c| c == '<');

    if let Some('<') = s.eat() {
        match s.peek() {
            Some('@') => github_handle(&mut s)?,
            Some(_) => {
                if s.after().starts_with("http://") || s.after().starts_with("https://") {
                    let url = s.eat_until(|c| c == '>');
                    if !url.chars().all(is_legal_in_url) {
                        bail!("URL contains invalid characters");
                    }
                    if s.eat() != Some('>') {
                        bail!("Expected '>'");
                    }
                } else {
                    email(&mut s)?;
                }
            }
            None => bail!("Unexpected end of input"),
        }
    }

    Ok(())
}

fn github_handle(s: &mut Scanner) -> anyhow::Result<()> {
    // The username must start with an @
    if !s.eat_if('@') {
        bail!("GitHub username must start with an @");
    }

    // The first character must be alphanumeric
    if !s.eat_if(|c: char| c.is_ascii_alphanumeric()) {
        bail!("GitHub username must start with an alphanumeric character");
    }

    let mut length = 1;
    let mut last_was_hyphen = false;
    while let Some(c) = s.eat() {
        if length >= 39 {
            bail!("GitHub username cannot be longer than 39 characters");
        }

        match c {
            '-' if last_was_hyphen => bail!("GitHub username cannot contain consecutive hyphens"),
            '-' => last_was_hyphen = true,
            c if c.is_ascii_alphanumeric() => last_was_hyphen = false,
            '>' if last_was_hyphen => bail!("GitHub username cannot end with a hyphen"),
            '>' => return Ok(()),
            _ => bail!("GitHub username can only contain alphanumeric characters and hyphens"),
        }

        length += 1;
    }

    bail!("Unexpected end of input");
}

fn email(s: &mut Scanner) -> anyhow::Result<()> {
    #[derive(Debug, PartialEq, Eq)]
    enum EmailPart {
        Local,
        Domain,
        Tld,
    }

    let mut length = 0;
    let mut part = (EmailPart::Local, 0);
    while let Some(c) = s.eat() {
        if length >= 254 {
            bail!("Email cannot be longer than 254 characters");
        }

        part.1 += 1;

        match c {
            '@' if part.0 == EmailPart::Local => {
                if part.1 <= 1 {
                    bail!("Email local part cannot be empty");
                }

                part = (EmailPart::Domain, 0);
            }
            '.' if part.0 == EmailPart::Domain => {
                if part.1 <= 1 {
                    bail!("Email domain part cannot be empty");
                }

                part = (EmailPart::Tld, 0);
            }
            '>' if part.0 == EmailPart::Tld && part.1 > 1 => {
                return Ok(());
            }
            c if part.0 == EmailPart::Local
                && (c.is_ascii_alphanumeric() || "!#$%&'*+-/=?^_`{|}~.".contains(c)) => {}
            c if part.0 != EmailPart::Local && (is_legal_in_url(c)) => {}
            _ => bail!("Email can only contain alphanumeric characters, dots and hyphens"),
        }

        length += 1;
    }

    bail!("Unexpected end of input");
}

fn is_legal_in_url(c: char) -> bool {
    c.is_ascii_alphanumeric() || "-_.~:/?#[]@!$&'()*+,;=".contains(c)
}

/// Whether a string is a valid Typst identifier.
///
/// In addition to what is specified in the [Unicode Standard][uax31], we allow:
/// - `_` as a starting character,
/// - `_` and `-` as continuing characters.
///
/// [uax31]: http://www.unicode.org/reports/tr31/
fn is_ident(string: &str) -> bool {
    let mut chars = string.chars();
    chars
        .next()
        .is_some_and(|c| is_id_start(c) && chars.all(is_id_continue))
}

/// Whether a character can start an identifier.
fn is_id_start(c: char) -> bool {
    is_xid_start(c) || c == '_'
}

/// Whether a character can continue an identifier.
fn is_id_continue(c: char) -> bool {
    is_xid_continue(c) || c == '_' || c == '-'
}

#[cfg(test)]
mod tests {
    use crate::check_author_name;

    #[test]
    fn parse_author_name() {
        check_author_name("Martin").unwrap();
        check_author_name("Martin <@reknih>").unwrap();
        check_author_name("Martin <https://mha.ug>").unwrap();
        check_author_name("Martin <martin.haug@typst.app>").unwrap();

        // Check wrong GitHub username
        assert!(check_author_name("Martin <@reknih->").is_err());
        assert!(check_author_name("Martin <@-reknih>").is_err());
        assert!(check_author_name("Martin <@räknih>").is_err());
        assert!(check_author_name("Martin <@reknih").is_err());

        // Check wrong email addresses
        assert!(check_author_name("Martin <>").is_err());
        assert!(check_author_name("Martin <martin>").is_err());
        assert!(check_author_name("Martin <m@.de>").is_err());
        assert!(check_author_name("Martin <m@hello.>").is_err());
        assert!(check_author_name("Martin < >").is_err());
        assert!(check_author_name("Martin <martin@typst.app").is_err());

        // Check wrong URLs
        assert!(check_author_name("Martin <http://mha ug>").is_err());
        assert!(check_author_name("Martin <http://mhä.ug>").is_err());
        assert!(check_author_name("Martin <http://mha.ug").is_err());
    }
}
