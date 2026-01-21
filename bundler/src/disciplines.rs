/// Validate that this is a Typst universe discipline.
pub fn validate_discipline(discipline: &str) -> anyhow::Result<()> {
    match discipline {
        "agriculture" => {}
        "anthropology" => {}
        "archaeology" => {}
        "architecture" => {}
        "biology" => {}
        "business" => {}
        "chemistry" => {}
        "communication" => {}
        "computer-science" => {}
        "design" => {}
        "drawing" => {}
        "economics" => {}
        "education" => {}
        "engineering" => {}
        "environment" => {}
        "fashion" => {}
        "film" => {}
        "geography" => {}
        "geology" => {}
        "history" => {}
        "journalism" => {}
        "law" => {}
        "linguistics" => {}
        "literature" => {}
        "mathematics" => {}
        "medicine" => {}
        "music" => {}
        "painting" => {}
        "philosophy" => {}
        "photography" => {}
        "physics" => {}
        "politics" => {}
        "psychology" => {}
        "sociology" => {}
        "theater" => {}
        "theology" => {}
        "transportation" => {}
        _ => anyhow::bail!("unknown discipline"),
    }

    Ok(())
}
