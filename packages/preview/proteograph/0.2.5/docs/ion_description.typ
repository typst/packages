/// Ion description
#let ion-description (
/// Ion charge
  /// -> integer
    "charge": 1,
    
/// Ion intensity
  /// -> float
    "intensity": none,
    
/// Ion experimental mass on charge ratio
  /// -> float
    "mz": none,
    
/// Ion theoretical mass on charge ratio. *Optional*.
  /// -> float
    "mzth": none,
    
/// Ion size : number of residues for this fragment
  /// -> integer
    "size": 1
) = {return (
    "charge": charge,
    "intensity": intensity,
    "mz": mz,
    "mzth": mzth,
    "size": size
  )}
