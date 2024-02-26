use core::time;
use std::collections::HashMap;
use std::env::args;
use std::fs;
use std::io;
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{bail, Context};
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use semver::Version;
use serde::{Deserialize, Serialize};

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
            .ok_or_else(|| anyhow::Error::msg("cannot read namespace folder name"))?
            .to_str()
            .context("invalid namespace")?;

        println!("Processing namespace: {}", namespace);
        let mut paths = vec![];
        let mut index = vec![];
        fs::create_dir_all(Path::new(&out_dir).join(namespace))?;

        for entry in walkdir::WalkDir::new(&path).min_depth(2).max_depth(2) {
            let entry = entry?;
            if !entry.metadata()?.is_dir() {
                continue;
            }

            let path = entry.into_path();
            let info = process_package(&path, namespace, &out_dir)
                .with_context(|| format!("failed to process package at {}", path.display()))?;

            paths.push(path);
            index.push(info);
        }

        println!("Determining timestamps.");
        determine_timestamps(&paths, &mut index)?;

        // Sort the index.
        index.sort_by_key(|info| (info.package.name.clone(), info.package.version.clone()));

        println!("Writing index.");
        fs::write(
            Path::new(&out_dir).join(namespace).join("index.json"),
            serde_json::to_vec(&index.iter().map(|info| &info.package).collect::<Vec<_>>())?,
        )?;
        fs::write(
            Path::new(&out_dir).join(namespace).join("index.full.json"),
            serde_json::to_vec(&index)?,
        )?;
    }

    println!("Done.");

    Ok(())
}

/// Create an archive for a package.
fn process_package(
    path: &Path,
    namespace: &str,
    out_dir: &str,
) -> anyhow::Result<ExtendedPackageInfo> {
    println!("Bundling {}.", path.display());
    let PackageManifest { package, .. } =
        parse_manifest(path, namespace).context("failed to parse package manifest")?;

    let buf = build_archive(path, &package.exclude).context("failed to build archive")?;
    let readme = read_readme(path)?;

    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&package, &buf, namespace, out_dir).context("failed to write archive")?;

    Ok(ExtendedPackageInfo {
        package,
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
    out_dir: &str,
) -> anyhow::Result<()> {
    let path = Path::new(out_dir).join(format!(
        "{}/{}-{}.tar.gz",
        namespace, info.name, info.version
    ));
    fs::write(path, buf)?;
    Ok(())
}

/// Determine all packages timestamps.
fn determine_timestamps(
    paths: &[PathBuf],
    index: &mut [ExtendedPackageInfo],
) -> anyhow::Result<()> {
    // Check if git is installed on the system.
    let has_git = Command::new("git").arg("--version").status().is_ok();

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
            .entry(info.package.name.clone())
            .and_modify(|v| *v = (*v).min(t))
            .or_insert(t);
    }

    // Write update & release dates.
    for (info, &t) in index.iter_mut().zip(&timestamps) {
        info.updated_at = t;
        info.released_at = release_dates[&info.package.name];
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
    package: PackageInfo,
    /// The compressed archive size in bytes.
    size: usize,
    /// The unsanitized README markdown.
    readme: String,
    /// Release time of this version of the package.
    updated_at: u64,
    /// Release time of the first version of this package.
    released_at: u64,
}

/// A parsed package manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
struct PackageManifest {
    package: PackageInfo,
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

/// The `tool` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct Tool {}
