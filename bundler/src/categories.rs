use serde::{Deserialize, Serialize};

/// Which kind of package this is.
#[derive(Debug, Clone, Eq, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields, rename_all = "kebab-case")]
pub enum Category {
    // Functional categories.
    Components,
    Model,
    Languages,
    Layout,
    Text,
    Scripting,
    Integration,
    Visualization,
    Utility,
    Fun,

    // Publication categories.
    Book,
    Report,
    Paper,
    Thesis,
    Poster,
    Flyer,
    Presentation,
    Cv,
    Office,
}
