# vuln-calc

Calculate CVSS v4.0 scores from Typst. Useful for automatically calculating CVSS scores
in cyber security reports. 

The code of this package is based on the 
[FIRST CVSSv4 calculator](https://github.com/FIRSTdotorg/cvss-v4-calculator/).

## Usage

The `calculate-cvss-score` function can be given a CVSSv4 vector, 
and returns the CVSS score as a two-digit floating number. 

```typst
#import "@preview/vuln-calc:1.0.0": *

// Returns 8.7
#calculate-cvss-score(
  "CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N"
) 
```

The function also accepts dictionaries with metric keys in either upper or lower case:

```typst
// Returns 7.2 
#calculate-cvss-score((
  av: "A",
  ac: "L",
  at: "N",
  pr: "N",
  ui: "N",
  vc: "L",
  vi: "H",
  va: "L",
  sc: "N",
  si: "N",
  sa: "N",
)) 
```

Additionally, the package includes functions to get the severity based on the CVSS vector
or score:

```typst
// Returns "High"
#calculate-cvss-severity("CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N") 

// Returns "Critical"
#get-cvss-score-severity(9.2) 
```