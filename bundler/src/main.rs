use std::collections::HashMap;
use std::fs;
use std::io;
use std::path::Path;
use std::process::Command;

use anyhow::{bail, Context};
use semver::Version;
use serde::{Deserialize, Serialize};

type ReleaseMap = HashMap<String, Option<u64>>;

fn main() -> anyhow::Result<()> {
    fs::create_dir_all("dist/preview")?;

    println!("Starting bundling.");

    let mut index = vec![];
    let mut release_dates: ReleaseMap = HashMap::new();

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
            process_package(path, &mut release_dates)
                .with_context(|| format!("failed to process package at {}", path.display()))?,
        );
    }

    println!("Writing index.");
    index.sort_by_key(|pkg| (pkg.package.name.clone(), pkg.package.version.clone()));
    fs::write(
        "dist/preview/index.json",
        serde_json::to_vec(&index.iter().map(|i| i.package.clone()).collect::<Vec<_>>())?,
    )?;
    fs::write("dist/preview/index.full.json", serde_json::to_vec(&index)?)?;

    println!("Done.");

    Ok(())
}

/// Create an archive for a package.
fn process_package(
    path: &Path,
    release_dates: &mut ReleaseMap,
) -> anyhow::Result<ExtendedPackageInfo> {
    println!("Bundling {}.", path.display());
    let PackageManifest { package, .. } =
        parse_manifest(path).context("failed to parse package manifest")?;
    let buf = build_archive(path, &package.exclude).context("failed to build archive")?;
    let readme = read_readme(path)?;
    let dates = package_dates(path, &package.name, release_dates)?;
    validate_archive(&buf).context("failed to validate archive")?;
    write_archive(&package, &buf).context("failed to write archive")?;

    Ok(ExtendedPackageInfo {
        package,
        readme,
        size: buf.len(),
        updated_at: dates.0,
        released_at: dates.1,
    })
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

    if manifest.package.category.len() > 3 {
        bail!(
            "expected up to three categories, got {}",
            manifest.package.category.len()
        );
    }

    Ok(manifest)
}

/// Retrieve the date of this and the first release using Git.
fn package_dates(
    dir_path: &Path,
    name: &str,
    release_dates: &mut ReleaseMap,
) -> anyhow::Result<(Option<u64>, Option<u64>)> {
    let get_timestamp = |path: &Path| -> anyhow::Result<Option<u64>> {
        // Call Git and get the Unix timestamp of a commit date (without using a
        // pager)
        let mut command = Command::new("git");
        command.args(["-P", "log", "--no-patch", "--format=%ct"]);
        command.arg(path.join("typst.toml"));

        // Returns `None` if the Git command is not available.
        // Fails if the Git reports an error or the number could not be parsed.
        let out: Option<Result<u64, anyhow::Error>> = command.output().map_or(None, |s| {
            if s.status.success() {
                Some(
                    String::from_utf8(s.stdout)
                        .map_err(Into::into)
                        .and_then(|s| {
                            let newline_idx = s.find('\n');
                            s[0..newline_idx.unwrap_or(s.len())]
                                .parse()
                                .map_err(Into::into)
                        }),
                )
            } else {
                Some(Err(anyhow::Error::msg(format!(
                    "execution failed: {:?}",
                    String::from_utf8(s.stderr)
                ))))
            }
        });

        out.transpose()
    };

    let updated_at = get_timestamp(dir_path)?;

    // Iterate the sibling directories.
    let released_at = if let Some(released_at) = release_dates.get(name) {
        *released_at
    } else {
        let parent = dir_path.parent().unwrap();
        let mut released_at = updated_at;

        for item in fs::read_dir(parent)? {
            let item = item?;
            let path = item.path();
            if path.is_dir() && path != dir_path {
                let time = get_timestamp(&path)?;
                released_at = match (released_at, time) {
                    (None, _) => time,
                    (Some(r), Some(t)) if r > t => time,
                    _ => released_at,
                }
            }
        }

        release_dates.insert(name.to_string(), released_at);
        released_at
    };

    Ok((updated_at, released_at))
}

/// Return the README file as a string.
fn read_readme(dir_path: &Path) -> anyhow::Result<String> {
    let path = dir_path.join("README.md");
    fs::read_to_string(path).context("failed to read README.md")
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
    #[serde(skip_serializing_if = "Vec::is_empty")]
    #[serde(default)]
    category: Vec<PackageCategory>,
}

/// Which kind of package is this?
#[derive(Debug, Copy, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
enum PackageCategory {
    /// Draw charts, plots, and figures.
    DrawingPlots,
    /// Icon packs
    Icons,
    /// Utility functions for code.
    Utility,
    /// Frameworks and helpers for handling external data and user input and
    /// templates that allow representing a lot of data.
    Data,
    /// Tools to handle multilingual documents.
    Localization,
    /// Layout building blocks and helpers.
    Layout,
    /// Packages and templates that help the user structure their document in a
    /// logical manner.
    Organization,
    /// Presentation builders and templates.
    Presentation,
    /// Tools for processing and styling string and text-heavy content.
    Text,
    /// Packages that improve typesetting formulas and equations.
    Mathematics,
    /// Packages that help to build a comprehensive bibliography.
    Bibliography,
    /// Templates and packages to write scientific papers.
    Paper,
    /// Domain-specific tools for scientific disciplines.
    Science,
    /// Templates and primitives for Curricula Vitae.
    #[serde(rename = "cv")]
    CV,
    /// University-specific templates.
    University,
    /// Templates for calendars and time management.
    Calendar,
    /// Templates and packages to create letters.
    Letter,
    /// Templates and packages to create reports.
    Report,
    /// Templates for grant and research proposals.
    Proposal,
}

#[derive(Debug, Clone, Eq, PartialEq, Serialize)]
struct ExtendedPackageInfo {
    /// The information from the package manifest.
    #[serde(flatten)]
    package: PackageInfo,
    /// The compressed archive size in bytes.
    size: usize,
    /// The unsanitized README markdown.
    readme: String,
    /// Release time of this version of the package.
    #[serde(skip_serializing_if = "Option::is_none")]
    updated_at: Option<u64>,
    /// Release time of the first version of this package.
    #[serde(skip_serializing_if = "Option::is_none")]
    released_at: Option<u64>,
}

/// The `tool` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
struct Tool {}
