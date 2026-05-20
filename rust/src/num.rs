pub trait Gcd {
    fn gcd(&self, other: &Self) -> Self;
}

impl Gcd for i32 {
    fn gcd(&self, other: &Self) -> Self {
        if other == &0 {
            self.abs()
        } else {
            other.gcd(&(self % other))
        }
    }
}

impl Gcd for i64 {
    fn gcd(&self, other: &Self) -> Self {
        if other == &0 {
            self.abs()
        } else {
            other.gcd(&(self % other))
        }
    }
}

pub trait Lcm {
    fn lcm(&self, other: &Self) -> Self;
}

impl Lcm for i32 {
    fn lcm(&self, other: &Self) -> Self {
        (self * other) / self.gcd(other)
    }
}

impl Lcm for i64 {
    fn lcm(&self, other: &Self) -> Self {
        (self * other) / self.gcd(other)
    }
}
