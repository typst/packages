use semver::Version;
use serde::{Deserialize, Serialize};

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
    pub name: String,
    pub version: Version,
    pub entrypoint: String,
    pub authors: Vec<String>,
    pub license: String,
    pub description: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub homepage: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub repository: Option<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub keywords: Vec<String>,
    #[serde(default)]
    #[serde(skip_serializing_if = "Vec::is_empty")]
    pub categories: Vec<PackageCategory>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub compiler: Option<Version>,
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

/// Which kind of package this is.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "kebab-case")]
pub enum PackageCategory {
    // Package kinds
    Components,
    Design,
    Model,
    Languages,
    Layout,
    Text,
    Scripting,
    Integration,
    Visualization,
    Utility,
    Fun,

    // Document kinds
    Book,
    Report,
    Paper,
    Thesis,
    Poster,
    Flyer,
    Presentation,
    Cv,
    Office,

    // Disciplines
    Education,
    Math,
    Physics,
    Chemistry,
    Biology,
    Economics,
    Engineering,
    ComputerScience,
    Law,
    Music,
    Arts,
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
