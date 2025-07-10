mod author;
mod categories;
mod disciplines;
mod model;
mod timestamp;

use std::env::args;
use std::fs;
use std::io;
use std::path::Path;
use std::sync::LazyLock;

use anyhow::{bail, Context};
use image::codecs::webp::{WebPEncoder, WebPQuality};
use image::imageops::FilterType;
use semver::Version;
use spdx::LicenseId;
use typst_syntax::package::{PackageInfo, PackageManifest, TemplateInfo, UnknownFields};
use unicode_ident::{is_xid_continue, is_xid_start};

use self::author::validate_author;
use self::categories::validate_category;
use self::disciplines::validate_discipline;
use self::model::*;
use self::timestamp::determine_timestamps;

const DIST: &str = "dist";
const THUMBS_DIR: &str = "thumbnails";

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
        let entry = entry.context("cannot read entries in directory \"packages\".\nHint: does the current working directory contain a directory \"packages\"?")?;
        if !entry
            .metadata()
            .context("cannot read metadata for entries in directory \"packages\"")?
            .is_dir()
        {
            continue;
        }

        let path = entry.into_path();
        let namespace = path
            .file_name()
            .context("cannot read namespace folder name")?
            .to_str()
            .context("invalid namespace")?;

        println!("Processing namespace: {}", namespace);
        let namespace_dir = Path::new(&out_dir).join(namespace);

        let mut paths = vec![];
        let mut index = vec![];
        let mut package_errors = vec![];
        fs::create_dir_all(namespace_dir.join(THUMBS_DIR))
            .context("could not create output directory")?;

        for entry in walkdir::WalkDir::new(&path).min_depth(2).max_depth(2) {
            let entry = entry.with_context(|| {
                format!(
                    "could not read item in namespace directory \"packages/{}\"",
                    namespace
                )
            })?;

            if !entry
                .metadata()
                .with_context(|| {
                    format!(
                        "could not read metadata for item in namespace directory \"packages/{}\"",
                        namespace
                    )
                })?
                .is_dir()
            {
                bail!(
                    "{}: a package directory may only contain version sub-directories, not files.",
                    entry.path().display()
                );
            }

            let path = entry.into_path();

            if path
                .file_name()
                .and_then(|name| name.to_str())
                .and_then(|name| Version::parse(name).ok())
                .is_none()
            {
                bail!(
                    "{}: Directory is not a valid version number",
                    path.display()
                );
            }

            match process_package(&path, &namespace_dir, namespace)
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
        determine_timestamps(&paths, &mut index)
            .context("failed to determine package creation timestamps")?;

        // Sort the index.
        index.sort_by_key(|info| (info.package.name.clone(), info.package.version));

        println!("Writing index.");
        fs::write(
            namespace_dir.join("index.json"),
            serde_json::to_vec(&index.iter().map(IndexPackageInfo::from).collect::<Vec<_>>())
                .context("serialization of compact package index failed")?,
        )?;
        fs::write(
            namespace_dir.join("index.full.json"),
            serde_json::to_vec(&index).context("serialization of full package index failed")?,
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
    namespace_dir: &Path,
    namespace: &str,
) -> anyhow::Result<FullIndexPackageInfo> {
    println!("Bundling {}.", path.display());

    let manifest = parse_manifest(path, namespace).context("failed to parse package manifest")?;
    let buf = build_archive(path, &manifest).context("failed to build archive")?;
    let readme = read_readme(path)?;

    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&manifest.package, &buf, namespace_dir).context("failed to write archive")?;

    if let Some(template) = &manifest.template {
        process_thumbnail(path, &manifest, template, namespace_dir)
            .context("failed to process thumbnail")?;
    }

    Ok(FullIndexPackageInfo {
        package: manifest.package,
        template: manifest.template,
        readme,
        size: buf.len(),
        // These will be filled in later.
        updated_at: 0,
        released_at: 0,
    })
}

fn validate_no_unknown_fields(
    unknown_fields: &UnknownFields,
    key: Option<&str>,
) -> anyhow::Result<()> {
    if !unknown_fields.is_empty() {
        match key {
            Some(key) => bail!(
                "unknown fields in `{key}`: {:?}",
                unknown_fields.keys().collect::<Vec<_>>()
            ),
            None => bail!(
                "unknown fields: {:?}",
                unknown_fields.keys().collect::<Vec<_>>()
            ),
        }
    }

    Ok(())
}

/// Read and validate the package's manifest.
fn parse_manifest(path: &Path, namespace: &str) -> anyhow::Result<PackageManifest> {
    let src = fs::read_to_string(path.join("typst.toml"))?;

    let manifest: PackageManifest = toml::from_str(&src)?;
    let expected = format!(
        "packages/{namespace}/{}/{}",
        manifest.package.name, manifest.package.version
    );

    validate_no_unknown_fields(&manifest.unknown_fields, None)?;
    validate_no_unknown_fields(&manifest.package.unknown_fields, Some("package"))?;

    if path != Path::new(&expected) {
        bail!("package directory name and manifest are mismatched");
    }

    if !is_ident(&manifest.package.name) {
        bail!("package name is not a valid identifier");
    }

    for author in &manifest.package.authors {
        validate_author(author).context("error while checking author name")?;
    }

    if manifest.package.description.is_none() {
        bail!("package description is missing");
    }

    if manifest.package.categories.len() > 3 {
        bail!("package can have at most 3 categories");
    }

    for category in &manifest.package.categories {
        validate_category(category)?;
    }

    for discipline in &manifest.package.disciplines {
        validate_discipline(discipline)?;
    }

    let Some(license) = &manifest.package.license else {
        bail!("package license is missing");
    };

    let license =
        spdx::Expression::parse(license).context("failed to parse SPDX license expression")?;

    for requirement in license.requirements() {
        let id = requirement
            .req
            .license
            .id()
            .context("license must not contain a referencer")?;

        if !id.is_osi_approved() && !is_allowed_cc(id) {
            bail!(
                "license is neither OSI approved nor an allowed CC license: {}",
                id.full_name
            );
        }
    }

    let entrypoint = path.join(manifest.package.entrypoint.as_str());
    validate_typst_file(&entrypoint, "package entrypoint")?;

    if let Some(template) = &manifest.template {
        validate_no_unknown_fields(&template.unknown_fields, Some("template"))?;

        if manifest.package.categories.is_empty() {
            bail!("template packages must have at least one category");
        }

        let entrypoint = path
            .join(template.path.as_str())
            .join(template.entrypoint.as_str());
        validate_typst_file(&entrypoint, "template entrypoint")?;
    }

    Ok(manifest)
}

/// Return the README file as a string.
fn read_readme(dir_path: &Path) -> anyhow::Result<String> {
    fs::read_to_string(dir_path.join("README.md")).context("failed to read README.md")
}

/// Build a compressed archive for a directory.
fn build_archive(dir_path: &Path, manifest: &PackageManifest) -> anyhow::Result<Vec<u8>> {
    let mut buf = vec![];
    let compressed = flate2::write::GzEncoder::new(&mut buf, flate2::Compression::default());
    let mut builder = tar::Builder::new(compressed);
    builder.mode(tar::HeaderMode::Deterministic);

    let mut overrides = ignore::overrides::OverrideBuilder::new(dir_path);
    for exclusion in &manifest.package.exclude {
        if exclusion.starts_with('!') {
            bail!("globs with '!' are not supported");
        }
        let exclusion = exclusion.trim_start_matches("./");
        overrides.add(&format!("!{exclusion}"))?;
    }

    // Always ignore the thumbnail.
    if let Some(template) = &manifest.template {
        overrides.add(&format!("!{}", template.thumbnail))?;
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
fn write_archive(info: &PackageInfo, buf: &[u8], namespace_dir: &Path) -> anyhow::Result<()> {
    let path = namespace_dir.join(format!("{}-{}.tar.gz", info.name, info.version));
    fs::write(path, buf)?;
    Ok(())
}

/// Process the thumbnail image for a package and write it to the `dist`
/// directory in large and small version.
fn process_thumbnail(
    path: &Path,
    manifest: &PackageManifest,
    template: &TemplateInfo,
    namespace_dir: &Path,
) -> anyhow::Result<()> {
    let original_path = path.join(template.thumbnail.as_str());
    let thumb_dir = namespace_dir.join(THUMBS_DIR);
    let filename = format!("{}-{}", manifest.package.name, manifest.package.version);
    let hopefully_max_encoded_size = 1024 * 1024;

    let extension = original_path
        .extension()
        .context("thumbnail has no extension")?
        .to_ascii_lowercase();

    if extension != "png" && extension != "webp" {
        bail!("thumbnail must be a PNG or WebP image");
    }

    // Get file size.
    let file_size = fs::metadata(&original_path)?.len() as usize;
    if file_size > 3 * 1024 * 1024 {
        bail!("thumbnail must be smaller than 3MB");
    }

    let mut image = image::open(&original_path)?;

    // Ensure that the image has at least a certain minimum size.
    let longest_edge = image.width().max(image.height());
    if longest_edge < 1080 {
        bail!("each thumbnail's longest edge must be at least 1080px long");
    }

    // We produce a full-size and a miniature thumbnail.
    let thumbnail_path = thumb_dir.join(format!("{filename}.webp"));
    let miniature_path = thumb_dir.join(format!("{filename}-small.webp"));

    // Choose a fast filter for the miniature.
    let miniature = image.resize(400, 400, FilterType::CatmullRom);
    let miniature_buf = encode_webp(&miniature, 85)?;
    fs::write(miniature_path, miniature_buf)?;

    // Thumbnails that are WebP already and in the budget should be copied as-is.
    if extension == "webp" && file_size < hopefully_max_encoded_size {
        fs::copy(&original_path, thumbnail_path)?;
        return Ok(());
    }

    // Try to encode as WebP without resizing. If that fits into the budget,
    // we're done.
    let mut quality = 98;
    let buf = encode_webp(&image, quality)?;
    if buf.len() < hopefully_max_encoded_size {
        fs::write(&thumbnail_path, buf)?;
    }

    // We're still too big. Fix it.
    if longest_edge <= 1920 {
        // Resizing doesn't help. Reduce quality instead.
        quality = 70;
    } else {
        image = image.resize(1920, 1920, FilterType::Lanczos3);
    }

    let buf = encode_webp(&image, quality)?;
    fs::write(&thumbnail_path, buf)?;

    Ok(())
}

/// Encodes a lossy WebP.
fn encode_webp(image: &image::DynamicImage, quality: u8) -> anyhow::Result<Vec<u8>> {
    // A big fight is going on in the Image crate's GitHub: They want to
    // remove the C dependency for WebP encoding but the Rust alternative
    // does not support lossy encoding. Many people are unhappy about this.
    let mut buf = Vec::new();
    #[allow(deprecated)]
    WebPEncoder::new_with_quality(&mut buf, WebPQuality::lossy(quality)).encode(
        image.to_rgb8().as_raw(),
        image.width(),
        image.height(),
        image::ColorType::Rgb8,
    )?;
    Ok(buf)
}

/// Check that a Typst file exists, its name ends in `.typ`, and that it is valid
/// UTF-8.
fn validate_typst_file(path: &Path, name: &str) -> anyhow::Result<()> {
    if !path.exists() {
        bail!("{name} is missing");
    }

    if path.extension().is_none_or(|ext| ext != "typ") {
        bail!("{name} must have a .typ extension");
    }

    fs::read_to_string(path).context("failed to read {name} file")?;
    Ok(())
}

/// Whether a string is a valid Typst identifier.
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

// Check that a license is any version of CC-BY, CC-BY-SA, or CC0.
fn is_allowed_cc(license: LicenseId) -> bool {
    static RE: LazyLock<regex::Regex> =
        LazyLock::new(|| regex::Regex::new(r"^CC(-BY|-BY-SA|0)-[0-9]\.[0-9](-[A-Z]+)?$").unwrap());

    RE.is_match(license.name)
}
