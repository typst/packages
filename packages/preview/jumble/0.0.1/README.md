<p align="center">
  <picture>
    <source media="(prefers-color-scheme: light)" srcset="gallery/readme_banner_light.svg" />
    <source media="(prefers-color-scheme: dark)" srcset="gallery/readme_banner_dark.svg" />
    <img alt="Banner" src="gallery/readme_banner_default.svg" />
  </picture>
</p>

**Jumble** is [Typst](https://typst.app) package providing some common hashing functions, as well as other related algorithms.

## Available methods
- MD4
- MD5
- SHA1
- HMAC
- NTLM
- TOTP
- Base32 encoding / decoding

## Usage

For information, please refer to the [manual](manual.pdf)

To use this package, you can either:
- import the package as a module:
  ```typst
  #import "@preview/jumble:0.0.1"
  ...
  #jumble.md5(...)
  ```
- import only the functions you need:
  ```typst
  #import "@preview/jumble:0.0.1": md5
  ...
  #md5(...)
  ```
- import everything:
  ```typst
  #import "@preview/jumble:0.0.1": *
  ...
  #md5(...)
  ```

### Examples
<table>
<tr>
<th><strong>Typst</strong></th>
<th><strong>Result</strong></th>
</tr>
<tr>
<td>

```typst
#bytes-to-hex(ntlm("Bellevue"))
```
</td>
<td>

```
f59d0692bf73b6381e85902a476f097b
```
</td>
</tr>

<tr>
<td>

```typst
#bytes-to-hex(md4("Hello World!"))
```
</td>
<td>

```
b2a5cc34fc21a764ae2fad94d56fadf6
```
</td>
</tr>
</table>

(more documentation and examples are provided in the [manual](manual.pdf))
