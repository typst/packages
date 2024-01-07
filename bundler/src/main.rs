use std::fs;
use std::io;
use std::path::Path;

use anyhow::{bail, Context};
use semver::Version;
use serde::{Deserialize, Serialize};

fn main() -> anyhow::Result<()> {
    fs::create_dir_all("dist/preview")?;

    println!("Starting bundling.");

    let mut index = vec![];
    for entry in walkdir::WalkDir::new("packages/preview")
        .min_depth(2)
        .max_depth(2)
        .sort_by_file_name()
    {
        let entry = entry?;
        if !entry.metadata()?.is_dir() {
            continue;
        }

        let path = entry.path();
        index.push(
            process_package(path)
                .with_context(|| format!("failed to process package at {}", path.display()))?,
        );
    }

    println!("Writing index.");
    index.sort_by_key(|pkg| (pkg.name.clone(), pkg.version.clone()));
    fs::write("dist/preview/index.json", serde_json::to_vec(&index)?)?;

    println!("Done.");

    Ok(())
}

/// Create an archive for a package.
fn process_package(path: &Path) -> anyhow::Result<PackageInfo> {
    println!("Bundling {}.", path.display());
    let PackageManifest { package, .. } =
        parse_manifest(path).context("failed to parse package manifest")?;
    let buf = build_archive(path, &package.exclude).context("failed to build archive")?;
    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&package, &buf).context("failed to write archive")?;
    Ok(package)
}

/// Read and validate the package's manifest.
fn parse_manifest(path: &Path) -> anyhow::Result<PackageManifest> {
    let src = fs::read_to_string(path.join("typst.toml"))?;

    let manifest: PackageManifest = toml::from_str(&src)?;
    let expected = format!(
        "packages/preview/{}/{}",
        manifest.package.name, manifest.package.version
    );

    if path != Path::new(&expected) {
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

/// Write a compressed archive to the `dist` directory.
fn write_archive(info: &PackageInfo, buf: &[u8]) -> anyhow::Result<()> {
    let path = format!("dist/preview/{}-{}.tar.gz", info.name, info.version);
    fs::write(path, buf)?;
    Ok(())
}

/// A parsed package manifest.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct PackageManifest {
    package: PackageInfo,
    #[serde(skip_serializing_if = "Option::is_none")]
    tool: Option<toml::Table>,
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
