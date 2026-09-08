use std::io::Cursor;

use image::{DynamicImage, ImageFormat, ImageReader, RgbaImage};
#[cfg(target_arch = "wasm32")]
wasm_minimal_protocol::initiate_protocol!();

#[cfg_attr(target_arch = "wasm32", wasm_minimal_protocol::wasm_func)]
pub fn key_out(
    source: &[u8],
    color: &[u8],
    tolerance: &[u8],
    softness: &[u8],
    space: &[u8],
    premultiply: &[u8],
    format: &[u8],
) -> Result<Vec<u8>, String> {
    let key = parse_color(color)?;
    let tolerance = parse_ratio(tolerance, "tolerance")?;
    let softness = parse_ratio(softness, "softness")?;
    let space = parse_text(space, "space")?;
    let premultiply = parse_bool(premultiply, "premultiply")?;
    let format = parse_text(format, "format")?;

    if space != "srgb" {
        return Err(format!(
            "unsupported color space `{space}`; expected `srgb`"
        ));
    }

    let mut img = decode_image(source, format)?.to_rgba8();
    apply_key(&mut img, key, tolerance, softness, premultiply);
    encode_png(&img)
}

fn decode_image(source: &[u8], format: &str) -> Result<DynamicImage, String> {
    let cursor = Cursor::new(source);

    if format == "auto" {
        return ImageReader::new(cursor)
            .with_guessed_format()
            .map_err(|err| format!("could not guess image format: {err}"))?
            .decode()
            .map_err(|err| format!("could not decode image: {err}"));
    }

    let image_format = match format {
        "png" => ImageFormat::Png,
        "jpg" | "jpeg" => ImageFormat::Jpeg,
        "gif" => ImageFormat::Gif,
        "webp" => ImageFormat::WebP,
        other => return Err(format!("unsupported image format `{other}`")),
    };

    image::load(cursor, image_format).map_err(|err| format!("could not decode image: {err}"))
}

fn apply_key(img: &mut RgbaImage, key: [f32; 3], tolerance: f32, softness: f32, premultiply: bool) {
    let max_distance = 3.0_f32.sqrt();

    for pixel in img.pixels_mut() {
        let rgb = [
            f32::from(pixel[0]) / 255.0,
            f32::from(pixel[1]) / 255.0,
            f32::from(pixel[2]) / 255.0,
        ];
        let distance =
            (((rgb[0] - key[0]).powi(2) + (rgb[1] - key[1]).powi(2) + (rgb[2] - key[2]).powi(2))
                .sqrt()
                / max_distance)
                .clamp(0.0, 1.0);

        let keep = if distance <= tolerance {
            0.0
        } else if softness <= f32::EPSILON || distance >= tolerance + softness {
            1.0
        } else {
            smoothstep((distance - tolerance) / softness)
        };

        let alpha = (f32::from(pixel[3]) * keep).round().clamp(0.0, 255.0) as u8;
        pixel[3] = alpha;

        if premultiply {
            let scale = f32::from(alpha) / 255.0;
            pixel[0] = (f32::from(pixel[0]) * scale).round().clamp(0.0, 255.0) as u8;
            pixel[1] = (f32::from(pixel[1]) * scale).round().clamp(0.0, 255.0) as u8;
            pixel[2] = (f32::from(pixel[2]) * scale).round().clamp(0.0, 255.0) as u8;
        }
    }
}

fn smoothstep(value: f32) -> f32 {
    let value = value.clamp(0.0, 1.0);
    value * value * (3.0 - 2.0 * value)
}

fn encode_png(img: &RgbaImage) -> Result<Vec<u8>, String> {
    let mut output = Cursor::new(Vec::new());
    DynamicImage::ImageRgba8(img.clone())
        .write_to(&mut output, ImageFormat::Png)
        .map_err(|err| format!("could not encode png: {err}"))?;
    Ok(output.into_inner())
}

fn parse_color(input: &[u8]) -> Result<[f32; 3], String> {
    let text = parse_text(input, "color")?;
    let hex = text.trim().trim_start_matches('#');
    let hex = match hex.len() {
        6 | 8 => hex.to_string(),
        3 | 4 => hex.chars().flat_map(|ch| [ch, ch]).collect(),
        _ => return Err(format!("invalid color `{text}`; expected hex RGB or RGBA")),
    };

    let r = parse_hex_pair(&hex[0..2], &text)?;
    let g = parse_hex_pair(&hex[2..4], &text)?;
    let b = parse_hex_pair(&hex[4..6], &text)?;
    Ok([
        f32::from(r) / 255.0,
        f32::from(g) / 255.0,
        f32::from(b) / 255.0,
    ])
}

fn parse_hex_pair(pair: &str, original: &str) -> Result<u8, String> {
    u8::from_str_radix(pair, 16).map_err(|_| format!("invalid color `{original}`"))
}

fn parse_ratio(input: &[u8], name: &str) -> Result<f32, String> {
    let text = parse_text(input, name)?;
    let trimmed = text.trim();
    let value = if let Some(percent) = trimmed.strip_suffix('%') {
        percent
            .trim()
            .parse::<f32>()
            .map_err(|_| format!("invalid {name} `{text}`"))?
            / 100.0
    } else {
        trimmed
            .parse::<f32>()
            .map_err(|_| format!("invalid {name} `{text}`"))?
    };

    if !(0.0..=1.0).contains(&value) {
        return Err(format!("{name} must be between 0% and 100%"));
    }

    Ok(value)
}

fn parse_bool(input: &[u8], name: &str) -> Result<bool, String> {
    match parse_text(input, name)? {
        "true" => Ok(true),
        "false" => Ok(false),
        other => Err(format!("invalid {name} `{other}`; expected true or false")),
    }
}

fn parse_text<'a>(input: &'a [u8], name: &str) -> Result<&'a str, String> {
    std::str::from_utf8(input).map_err(|_| format!("{name} must be valid UTF-8"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn keys_exact_white_to_transparent_png() {
        let mut input = Cursor::new(Vec::new());
        DynamicImage::ImageRgba8(RgbaImage::from_fn(2, 1, |x, _| {
            if x == 0 {
                image::Rgba([255, 255, 255, 255])
            } else {
                image::Rgba([0, 0, 0, 255])
            }
        }))
        .write_to(&mut input, ImageFormat::Png)
        .unwrap();

        let output = key_out(
            input.get_ref(),
            b"ffffff",
            b"0%",
            b"0%",
            b"srgb",
            b"false",
            b"auto",
        )
        .unwrap();

        let keyed = image::load_from_memory(&output).unwrap().to_rgba8();
        assert_eq!(keyed.get_pixel(0, 0).0, [255, 255, 255, 0]);
        assert_eq!(keyed.get_pixel(1, 0).0, [0, 0, 0, 255]);
    }
}
