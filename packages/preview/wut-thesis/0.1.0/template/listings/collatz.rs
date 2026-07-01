struct Collatz {
    current_value: u32,
}

impl Collatz {
    fn new(initial_value: u32) -> Self {
        Collatz {
            current_value: initial_value,
        }
    }

    fn update_val(&mut self) {
        if self.current_value % 2 == 0 {
            self.current_value /= 2;
        } else {
            self.current_value = self.current_value * 3 + 1;
        }
    }

    fn print_sequence(&mut self) {
        let mut i = 1;
        while self.current_value > 1 {
            println!("value {} = {}", i, self.current_value);
            self.update_val();
            i += 1;
        }
    }
}

fn main() {
    // prints Collatz sequence, starting from 194375
    let mut seq = Collatz::new(194_375);
    seq.print_sequence();
}
