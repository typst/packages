use std::fs;
use std::io;
use std::path::Path;

use anyhow::{bail, Context};
use serde::{Deserialize, Serialize};

fn main() -> anyhow::Result<()> {
    fs::create_dir_all("dist/preview")?;

    println!("Starting bundling.");

    let mut index = vec![];
    for entry in fs::read_dir("packages/preview")? {
        let entry = entry?;
        if !entry.metadata()?.is_dir() {
            continue;
        }

        let path = entry.path();
        index.push(
            process_package(&path)
                .with_context(|| format!("failed to process package at {}", path.display()))?,
        );
    }

    println!("Writing index.");
    fs::write("dist/preview/index.json", serde_json::to_vec(&index)?)?;

    println!("Done.");

    Ok(())
}

/// Create an archive for a package.
fn process_package(path: &Path) -> anyhow::Result<IndexEntry> {
    println!("Bundling {}.", path.display());
    let PackageManifest { package } =
        parse_manifest(path).context("failed to parse package manifest")?;
    let buf = build_archive(path).context("failed to build archive")?;
    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&package, &buf).context("failed to write archive")?;
    Ok(IndexEntry {
        name: package.name,
        version: package.version,
        license: package.license,
        description: package.description,
    })
}

/// Read and validate the package's manifest.
fn parse_manifest(path: &Path) -> anyhow::Result<PackageManifest> {
    let src = fs::read_to_string(path.join("typst.toml"))?;

    let manifest: PackageManifest = toml::from_str(&src)?;
    let expected = format!("{}-{}", manifest.package.name, manifest.package.version);
    if path.file_name() != Some(expected.as_ref()) {
        bail!("package directory name and manifest are mismatched");
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
    if !entrypoint.exists() {
        bail!("package entry point is missing");
    }

    Ok(manifest)
}

/// Build a comrpessed archive for a directory.
fn build_archive(path: &Path) -> anyhow::Result<Vec<u8>> {
    let mut buf = vec![];
    let compressed = flate2::write::GzEncoder::new(&mut buf, flate2::Compression::default());
    let mut builder = tar::Builder::new(compressed);
    builder.append_dir_all(".", path)?;
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

/// Write a compressed archive to the `dist` directory.
fn write_archive(info: &PackageInfo, buf: &[u8]) -> anyhow::Result<()> {
    let path = format!("dist/preview/{}-{}.tar.gz", info.name, info.version);
    fs::write(path, buf)?;
    Ok(())
}

/// A parsed package manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct PackageManifest {
    package: PackageInfo,
}

/// The `package` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct PackageInfo {
    name: String,
    version: String,
    authors: Vec<String>,
    license: String,
    description: String,
    entrypoint: String,
}

/// An entry in the package index.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct IndexEntry {
    name: String,
    version: String,
    license: String,
    description: String,
}
