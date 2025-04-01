# My proposal

## Dependencies

- [华文字体](https://github.com/chengda/popular-fonts)
- [中易字体](https://github.com/StellarCN/scp_zh/tree/master/fonts)
- [方正字体](https://github.com/Kangzhengwei/androidFront)
- [Times New Roman](https://github.com/siaimes/pytorch/tree/main/fonts)
- [font-awesome](https://github.com/FortAwesome/Font-Awesome)

## Build

```sh
nix run '.#build'
# Or download all required fonts, then
typst compile main.typ
```
