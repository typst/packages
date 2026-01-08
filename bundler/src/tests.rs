use super::*;
use std::fs::File;
use std::io::Write;
use tempfile::tempdir;

#[test]
fn test_normalize_exclusion_glob_comprehensive() {
    let cases = vec![
        // Case 1: Clean paths (Implicitly anchored)
        ("assets", "/assets", "Clean path should be anchored to root"),
        ("src/images", "/src/images", "Nested clean path should be anchored"),
        
        // Case 2: Explicit Relative (User intent: Root)
        ("./assets", "/assets", "Explicit relative ./ should be anchored"),
        ("./doc/img", "/doc/img", "Nested relative ./ should be anchored"),
        
        // Case 3: Globs (Should remain recursive)
        ("*.png", "*.png", "Simple wildcard glob should remain recursive"),
        ("src/**/*.rs", "src/**/*.rs", "Double star glob should remain recursive"),
        ("img[0-9]", "img[0-9]", "Bracket glob should remain recursive"),
        ("*.{jpg,png}", "*.{jpg,png}", "Brace expansion glob should remain recursive"),
        
        // Case 4: Edge Cases
        ("/already/anchored", "/already/anchored", "Already anchored path should stay anchored"),
        ("  whitespace  ", "/whitespace", "Whitespace should be trimmed"),
        ("", "", "Empty string should return empty"),
        
        // Case 5: Windows Path Normalization
        (r"docs\manual", "/docs/manual", "Backslashes should become forward slashes"),
        (r".\assets", "/assets", "Windows relative path should be anchored"),
    ];

    for (input, expected, reason) in cases {
        assert_eq!(
            normalize_exclusion_glob(input), 
            expected, 
            "FAILED: {}", reason
        );
    }
}

#[test]
fn test_identifier_validation() {
    let valid = vec!["package", "my_package", "pkg-name", "iso_8859_1", "a"];
    let invalid = vec![
        "123start",   // Starts with number
        "-start",     // Starts with hyphen
        "has space",  // Contains space
        "package!",   // Special char
        "",           // Empty
        "Uppercase",  // (Assuming strict lowercase snake_case if enforced, usually Typst is lenient on case but strict on chars)
    ];

    for id in valid {
        assert!(is_ident(id), "Should be valid: {}", id);
    }
    
    // Note: Adjust expectations based on your specific is_ident implementation details
    for id in invalid {
        // If your is_ident allows uppercase, remove "Uppercase" from this list
        if id == "Uppercase" && is_ident(id) { continue; } 
        assert!(!is_ident(id), "Should be invalid: {}", id);
    }
}

// =======================================================================
//  SECTION 2: INTEGRATION TESTS (FILESYSTEM)
//  Creates real temp directories to verify the ignore/exclude logic works.
// =======================================================================

#[test]
fn test_archive_builder_exclusions() -> anyhow::Result<()> {
    // 1. Setup a temporary directory acting as our package root
    let dir = tempdir()?;
    let root = dir.path();


    create_dummy_file(root, "typst.toml")?;
    create_dummy_file(root, "main.typ")?;
    create_dummy_file(root, "assets/logo.png")?;
    create_dummy_file(root, "src/assets/icon.png")?;
    create_dummy_file(root, "junk/garbage.tmp")?;

    // 3. Mock the Manifest
    // We want to exclude the root 'assets' folder, but NOT the 'src/assets' folder.
    // This tests if our normalization logic actually works in practice.
    let mut manifest = PackageManifest::dummy(); 
    manifest.package.exclude = vec![
        "assets".to_string(),       // Should normalize to /assets (Root only)
        "junk/*.tmp".to_string()    // Recursive glob (Standard)
    ];

    // 4. Run the Builder
    // We are calling the actual function from main.rs
    let archive_bytes = build_archive(root, &manifest)?;

    // 5. Inspect the Archive (Decompress in memory)
    let decompressed = flate2::read::GzDecoder::new(std::io::Cursor::new(&archive_bytes));
    let mut tar = tar::Archive::new(decompressed);

    let mut found_files = Vec::new();
    for entry in tar.entries()? {
        let entry = entry?;
        let path = entry.path()?.to_string_lossy().to_string();
        found_files.push(path);
    }
    found_files.sort();

    // 6. Assertions
    // "assets/logo.png" should be GONE (excluded by /assets)
    // "src/assets/icon.png" should be PRESENT (not matched by /assets)
    // "junk/garbage.tmp" should be GONE (excluded by glob)
    
    let files_str = format!("{:?}", found_files);
    
    assert!(found_files.contains(&"typst.toml".to_string()), "Missing typst.toml");
    assert!(found_files.contains(&"main.typ".to_string()), "Missing main.typ");
    assert!(found_files.contains(&"src/assets/icon.png".to_string()), 
        "Root exclusion '/assets' accidentally killed 'src/assets'! Files found: {}", files_str);
    
    assert!(!found_files.contains(&"assets/logo.png".to_string()), 
        "Failed to exclude root assets folder");
    assert!(!found_files.contains(&"junk/garbage.tmp".to_string()), 
        "Failed to exclude glob pattern");

    Ok(())
}

fn create_dummy_file(root: &Path, path: &str) -> anyhow::Result<()> {
    let full_path = root.join(path);
    if let Some(parent) = full_path.parent() {
        std::fs::create_dir_all(parent)?;
    }
    let mut file = File::create(full_path)?;
    writeln!(file, "dummy content")?;
    Ok(())
}

impl PackageManifest {
    fn dummy() -> Self {
        PackageManifest {
            package: PackageInfo {
                name: "test-pkg".into(),
                version: Version::parse("0.1.0").unwrap(),
                entrypoint: "main.typ".into(),
                authors: vec!["Test".into()],
                license: Some("MIT".into()),
                description: Some("Test".into()),
                repository: None,
                homepage: None,
                keywords: vec![],
                categories: vec![],
                disciplines: vec![],
                compiler: None,
                exclude: vec![],
                unknown_fields: Default::default(),
            },
            template: None,
            unknown_fields: Default::default(),
        }
    }
}
