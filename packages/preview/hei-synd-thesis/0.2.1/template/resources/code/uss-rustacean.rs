struct Starship {
  name: String,
  position: (f64, f64, f64),
}

impl Starship {
  fn new(name: &str, position: (f64, f64, f64)) -> Self {
    Self {
      name: name.into(),
      position,
    }
  }
  fn distance_to(&self, dest: (f64, f64, f64)) -> f64 {
    ((dest.0 - self.position.0).powi(2)
      + (dest.1 - self.position.1).powi(2)
      + (dest.2 - self.position.2).powi(2))
    .sqrt()
  }
  fn optimal_warp(&self, distance: f64) -> f64 {
    (distance / 10.0).sqrt().min(9.0)
  }
}
