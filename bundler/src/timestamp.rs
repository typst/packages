use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

use anyhow::{bail, Context};
use ecow::EcoString;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};

use crate::FullIndexPackageInfo;

/// Determine all packages timestamps.
pub fn determine_timestamps(
    paths: &[PathBuf],
    index: &mut [FullIndexPackageInfo],
) -> anyhow::Result<()> {
    // Check if git is installed on the system.
    let has_git = Command::new("git").arg("--version").output().is_ok();

    // Determine timestamp via Git. Do this in parallel because it is pretty
    // slow.
    let timestamps = paths
        .par_iter()
        .map(|p| {
            if has_git {
                timestamp_for_path_with_git(p).or_else(|_| timestamp_for_path_with_fs(p))
            } else {
                timestamp_for_path_with_fs(p)
            }
        })
        .collect::<Result<Vec<_>, _>>()?;

    // Determine the release dates for all packages.
    // It is the minimum update date for any of its versions.
    let mut release_dates: HashMap<EcoString, u64> = HashMap::new();
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
