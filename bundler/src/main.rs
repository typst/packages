use std::fs;
use std::io;
use std::path::Path;

use anyhow::{bail, Context};
use serde::{Deserialize, Serialize};

fn main() -> anyhow::Result<()> {
    fs::create_dir_all("dist")?;

    println!("Starting bundling.");

    for entry in fs::read_dir("packages")? {
        let entry = entry?;
        if !entry.metadata()?.is_dir() {
            continue;
        }

        let path = entry.path();
        process_package(&path)
            .with_context(|| format!("failed to process package at {}", path.display()))?;
    }

    println!("Done.");

    Ok(())
}

/// Create an archive for a package.
fn process_package(path: &Path) -> anyhow::Result<()> {
    println!("Bundling {}.", path.display());
    let manifest = parse_manifest(path).context("failed to parse package manifest")?;
    let buf = build_archive(path).context("failed to build archive")?;
    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&manifest.package, &buf).context("failed to write archive")?;
    Ok(())
}

/// Read and validate the package's manifest.
fn parse_manifest(path: &Path) -> anyhow::Result<PackageManifest> {
    let src = fs::read_to_string(path.join("typst.toml"))?;

    let manifest: PackageManifest = toml::from_str(&src)?;
    let expected = format!("{}-{}", manifest.package.name, manifest.package.version);
    if path.file_name() != Some(expected.as_ref()) {
        bail!("package directory name and manifest are mismatched");
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
    let path = format!("dist/{}-{}.tar.gz", info.name, info.version);
    fs::write(path, buf)?;
    Ok(())
}

/// A parsed package manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
pub struct PackageManifest {
    package: PackageInfo,
}

/// The `package` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
pub struct PackageInfo {
    name: String,
    version: String,
    entrypoint: String,
}
