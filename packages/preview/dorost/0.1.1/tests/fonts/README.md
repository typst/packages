# Test font fixtures

The check script downloads checksum-pinned upstream archives into a temporary build directory and uses only the required font faces. Font binaries are not stored in this repository or included in the Typst package. The archives are cached under the user's cache directory and verified before use.

| Family | Version | Source | Included files |
| --- | --- | --- | --- |
| Vazirmatn | 33.003 | [upstream release](https://github.com/rastikerdar/vazirmatn/releases/tag/v33.003) | Regular and Bold TTFs; SIL Open Font License 1.1 |
| Lora | 3.021 | [upstream release](https://github.com/cyrealtype/Lora-Cyrillic/releases/tag/v3.021) | Regular, Bold, Italic, and BoldItalic TTFs; SIL Open Font License 1.1 |
| JetBrains Mono | 2.304 | [upstream release](https://github.com/JetBrains/JetBrainsMono/releases/tag/v2.304) | Regular and Bold TTFs; SIL Open Font License 1.1 |

Users should download fonts from the upstream releases and keep them in their own project or install them system-wide. Lora covers Latin; Vazirmatn supplies Persian glyphs. Math uses Typst's embedded math font. The test fetcher stores archive checksums and source URLs in `scripts/fetch-test-fonts.py`.
