/// Validate that this is a Typst universe category.
pub fn validate_category(category: &str) -> anyhow::Result<()> {
    match category {
        // Functional categories.
        "components" => {}
        "visualization" => {}
        "model" => {}
        "layout" => {}
        "text" => {}
        "languages" => {}
        "scripting" => {}
        "integration" => {}
        "utility" => {}
        "fun" => {}
        // Publication categories.
        "book" => {}
        "report" => {}
        "paper" => {}
        "thesis" => {}
        "poster" => {}
        "flyer" => {}
        "presentation" => {}
        "cv" => {}
        "office" => {}
        _ => anyhow::bail!("unknown category"),
    }

    Ok(())
}
