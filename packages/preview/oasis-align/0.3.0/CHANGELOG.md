## 0.3.0 - 2025/03/26 to 2025/06/21
- added the following parameters
    - `min-frac` 
    - `vertical` 
        - requested by @noobzik on Discord for presentations
        - note that certain behaviors with figures and other kinds of content yield strange results
    - `ruler`
    - `range` 
    - `force-frac`
    - `frac-limit`
- improved the `debug` output
- `int-frac` is now derived as mean of `range`
- refactored code base for easier legibility
- improve parameter verification using `assert()`
- re-added `oasis-align-images()`


## 0.2.0 - 2024/11/30
- removed `oasis-align-images()`
    - Thanks to @Aaron-Rumpler for pointing out a critical bug!
- added `swap` to parameters
    - switches positions of content
- cleaned up `debug` output to be more readable
- breaking scenarios are now treated as such with `panic`
    - Thanks again to @Aaron-Rumpler for the suggestion!
- no longer show error message if content is "incompatible" and will instead display state at `int-frac`
    - should make using `oasis-align()` way less frustrating to use
- default max iterations reduced from 50 to 30

## 0.1.0 - 2024/09/02
- Initial Release