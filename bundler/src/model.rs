use semver::Version;
use serde::{Deserialize, Serialize};

use crate::categories::Category;
use crate::disciplines::Discipline;

/// A parsed package manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PackageManifest {
    pub package: PackageInfo,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub template: Option<TemplateInfo>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tool: Option<Tool>,
}

/// The `package` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct PackageInfo {
    /// The package's identifier in its namespace.
    pub name: String,
    /// The package's version as a full major-minor-patch triple.
    pub version: Version,
    /// The path to the main Typst file that is evaluated when the package is
    /// imported.
    pub entrypoint: String,
    /// A list of the package's authors.
    pub authors: Vec<String>,
    ///  The package's license.
    pub license: String,
    /// A short description of the package.
    pub description: String,
    /// A link to the package's web presence.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub homepage: Option<String>,
    /// A link to the repository where this package is developed.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub repository: Option<String>,
    /// An array of search keywords for the package.
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub keywords: Vec<String>,
    /// An array with up to three of the predefined categories to help users
    /// discover the package.
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub categories: Vec<Category>,
    /// An array of disciplines defining the target audience for which the
    /// package is useful.
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub disciplines: Vec<Discipline>,
    /// The minimum Typst compiler version required for this package to work.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub compiler: Option<Version>,
    /// An array of globs specifying files that should not be part of the
    /// published bundle.
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub exclude: Vec<String>,
}

/// The `template` key in the manifest.
#[derive(Debug, Clone, Default, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct TemplateInfo {
    pub path: String,
    pub entrypoint: String,
    pub thumbnail: String,
}

/// The `tool` key in the manifest.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
pub struct Tool {}

/// A parsed package manifest with the release time.
#[derive(Debug, Clone, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct IndexPackageInfo {
    /// The package information from the package manifest.
    #[serde(flatten)]
    pub package: PackageInfo,
    /// The template information from the package manifest.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub template: Option<TemplateInfo>,
    /// Release time of this version of the package.
    pub updated_at: u64,
}

impl From<&FullIndexPackageInfo> for IndexPackageInfo {
    fn from(info: &FullIndexPackageInfo) -> Self {
        IndexPackageInfo {
            package: info.package.clone(),
            template: info.template.clone(),
            updated_at: info.updated_at,
        }
    }
}

/// A parsed package manifest + extra metadata.
#[derive(Debug, Clone, Eq, PartialEq, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct FullIndexPackageInfo {
    /// The package information from the package manifest.
    #[serde(flatten)]
    pub package: PackageInfo,
    /// The template information from the package manifest.
    #[serde(skip_serializing_if = "Option::is_none")]
    pub template: Option<TemplateInfo>,
    /// The compressed archive size in bytes.
    pub size: usize,
    /// The unsanitized README markdown.
    pub readme: String,
    /// Release time of this version of the package.
    pub updated_at: u64,
    /// Release time of the first version of this package.
    pub released_at: u64,
}
