mod author;
mod model;
mod timestamp;

use std::env::args;
use std::fs;
use std::io;
use std::path::Path;

use anyhow::{bail, Context};
use unicode_ident::{is_xid_continue, is_xid_start};

use self::author::validate_author;
use self::model::*;
use self::timestamp::determine_timestamps;

const DIST: &str = "dist";

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
) -> anyhow::Result<FullIndexPackageInfo> {
    println!("Bundling {}.", path.display());
    let PackageManifest { package, .. } =
        parse_manifest(path, namespace).context("failed to parse package manifest")?;

    let buf = build_archive(path, &package.exclude).context("failed to build archive")?;
    let readme = read_readme(path)?;

    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&package, &buf, namespace, out_dir).context("failed to write archive")?;

    Ok(FullIndexPackageInfo {
        base: package,
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
        validate_author(author).context("author field is invalid")?;
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
    validate_typst_file(&entrypoint, "entrypoint")?;

    Ok(manifest)
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

// Check that a Typst file exists, its name ends in `.typ`, and that it is valid
// UTF-8.
fn validate_typst_file(path: &Path, name: &str) -> anyhow::Result<()> {
    if !path.exists() {
        bail!("{name} is missing");
    }

    if path.extension().map_or(true, |ext| ext != "typ") {
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
