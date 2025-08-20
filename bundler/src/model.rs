use serde::Serialize;
use typst_syntax::package::{PackageInfo, TemplateInfo};

/// A parsed package manifest with the release time.
#[derive(Debug, Clone, Serialize)]
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
#[derive(Debug, Clone, Serialize)]
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
