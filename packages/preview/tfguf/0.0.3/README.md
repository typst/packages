
# TFG UNIR Física
This template is used to make bachelor thesis works for the [degree in Physics](http://bit.ly/unirfisica) at Universidad Internacional de La Rioja ([UNIR](http://unir.net)). 

![Moto of the Physics degree at UNIR University](https://p.ipic.vip/vbt7pt.jpg)

## Quick start
In order to use it, just import it and apply a `show` rule: 

```typst
#import "@local/tfguf:0.0.3": unirfisica
#show: unirfisica.with(titulo: "Mi trabajo de fin de grado", agradecimientos: [_A mi padre_], logo: image("unir logo.png", width: 60%))
```
If you do not have the **Calibri font familiy**, you can download it from [here](https://www.rmtweb.co.uk/calibri-and-cambria-fonts-for-mac). Once done, upload all the `Calibri*.ttf` files to your project directory.