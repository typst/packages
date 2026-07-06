# License

All the fonts downloaded by this script for the layout of the documents are licensed under the [SIL Open Font License](https://openfontlicense.org/) which is included in [here](ofl.md).

## Installing fonts

This report template uses several fonts packaged in this repository. To install the fonts in a Linux environment, simply type: 

```bash
source install_fonts.sh
```

from within the `fonts` directory and voilà!

The installer also creates a local fontconfig alias so Linux maps `Source Sans Pro` to `Source Sans 3`.
This keeps Typst/web template naming compatibility while avoiding missing-font warnings on Linux.
