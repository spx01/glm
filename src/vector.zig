const std = @import("std");
const math = std.math;

/// The type of a vector.
pub fn Vector(comptime N: usize) type {
  return packed struct {
    const Self = @This();
    /// The scalar type manager by this vector.
    pub const Scalar = f32;

    values: [N]Scalar,

    /// Initializes a vector from its scalar values.
    pub fn init(values: [N]Scalar) Self {
      return .{ .values = values };
    }

    /// Creates a vector filled with the given scalar value.
    pub fn filled(n: Scalar) Self {
      var values: [N]Scalar = undefined;
      comptime var i = 0;
      inline while (i < N) : (i += 1) {
        values[i] = n;
      }
      return .{ .values = values };
    }

    /// Creates a vector filled with zeroes.
    pub fn zeroes() Self {
      return comptime Self.filled(0);
    }

    /// Sums all scalars in this vector.
    pub fn sum(self: Self) Scalar {
      var total: Scalar = 0;

      comptime var i = 0;
      inline while (i < N) : (i += 1) {
        total += self.values[i];
      }

      return total;
    }

    /// Adds 2 vector together.
    pub fn add(self: Self, other: Self) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      return .{ .values = left + right };
    }

    /// Adds another vector to this vector.
    pub fn addAssign(self: *Self, other: Self) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      self.values = left + right;
    }

    /// Subtracts 2 vector together.
    pub fn sub(self: Self, other: Self) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      return .{ .values = left - right };
    }

    /// Adds another vector to this vector.
    pub fn subAssign(self: *Self, other: Self) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      self.values = left - right;
    }

    /// Multiplies 2 vectors together.
    pub fn mul(self: Self, other: Self) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      return .{ .values = left * right };
    }

    /// Multiplies a vector and a scalar together.
    pub fn mulScalar(self: Self, n: Scalar) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = Self.filled(n).values;

      return .{ .values = left * right };
    }

    /// Multiplies this vector with another vector.
    pub fn mulAssign(self: *Self, other: Self) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      self.values = left * right;
    }

    /// Multiplies this vector with a scalar.
    pub fn mulAssignScalar(self: *Self, n: Scalar) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = Self.filled(n).values;

      self.values = left * right;
    }

    /// Multiplies 2 vectors together.
    pub fn div(self: Self, other: Self) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      return .{ .values = left / right };
    }

    /// Multiplies a vector and a scalar together.
    pub fn divScalar(self: Self, n: Scalar) Self {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = Self.filled(n).values;

      return .{ .values = left / right };
    }

    /// Multiplies this vector with another vector.
    pub fn divAssign(self: *Self, other: Self) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = other.values;

      self.values = left / right;
    }

    /// Multiplies this vector with a scalar.
    pub fn divAssignScalar(self: *Self, n: Scalar) void {
      const left: @Vector(N, Scalar) = self.values;
      const right: @Vector(N, Scalar) = Self.filled(n).values;

      self.values = left / right;
    }

    /// Calculates the dot product of 2 vectors.
    pub fn dot(self: Self, other: Self) Scalar {
      return self.mul(other).sum();
    }

    /// Calculates the norm squared of this vector.
    pub fn normSquared(self: Self) Scalar {
      return self.dot(self);
    }

    /// Calculates the norm of this vector.
    pub fn norm(self: Self) Scalar {
      return math.sqrt(self.normSquared());
    }

    /// Returns a normalized version of this vector.
    pub fn normalize(self: Self) Self {
      const values: @Vector(N, Scalar) = self.values;
      const norms: @Vector(N, Scalar) = Self.filled(self.norm()).values;

      return .{ .values = values / norms };
    }

    /// Make this vector normalized.
    pub fn normalizeAssign(self: *Self) void {
      const values: @Vector(N, Scalar) = self.values;
      const norms: @Vector(N, Scalar) = Self.filled(self.norm()).values;

      self.values = values / norms;
    }

    /// Calculates the cross product of 2 vectors.
    pub fn cross(self: Self, other: Self) Self {
      if (N != 3) {
        @compileError("A cross product can only be calculated for a 3D vector.");
      }

      const values = [3]Scalar{
        self.values[1] * other.values[2] - self.values[2] * other.values[1],
        self.values[2] * other.values[0] - self.values[0] * other.values[2],
        self.values[0] * other.values[1] - self.values[1] * other.values[0],
      };

      return Self{ .values = values };
    }
  };
}

fn expectVectorEqual(comptime N: usize, expected: Vector(N), actual: Vector(N)) void {
  comptime var i = 0;
  inline while (i < N) : (i += 1) {
    std.testing.expectEqual(expected.values[i], actual.values[i]);
  }
}

test "vector initialization" {
  const actual = Vector(2).init(.{ 1, 2 });
  std.testing.expectEqual(@floatCast(f32, 1), actual.values[0]);
  std.testing.expectEqual(@floatCast(f32, 2), actual.values[1]);
}

test "vector scalar initialization" {
  const v = Vector(3).filled(3);
  expectVectorEqual(3, Vector(3).init(.{ 3, 3, 3 }), v);
}

test "vector zero initialization" {
  const v = Vector(3).zeroes();
  expectVectorEqual(3, Vector(3).init(.{ 0, 0, 0 }), v);
}

test "vector summation" {
  const v = Vector(3).init(.{ 1, 2, 3 });
  std.testing.expectEqual(@floatCast(f32, 6), v.sum());
}

test "vectors addition" {
  const v1 = Vector(3).init(.{ 3, 4, 5 });
  const v2 = Vector(3).init(.{ 6, 7, 8 });
  expectVectorEqual(3, Vector(3).init(.{ 9, 11, 13 }), v1.add(v2));

  var v3 = Vector(3).init(.{ 1, 2, 3 });
  v3.addAssign(Vector(3).init(.{ 3, 2, 1 }));
  expectVectorEqual(3, Vector(3).init(.{ 4, 4, 4 }), v3);
}

test "vectors subtraction" {
  const v1 = Vector(3).init(.{ 3, 4, 5 });
  const v2 = Vector(3).init(.{ 6, 7, 8 });
  expectVectorEqual(3, Vector(3).init(.{ -3, -3, -3 }), v1.sub(v2));

  var v3 = Vector(3).init(.{ 1, 2, 3 });
  v3.subAssign(Vector(3).init(.{ 3, 2, 1 }));
  expectVectorEqual(3, Vector(3).init(.{ -2, 0, 2 }), v3);
}

test "vector multiplication" {
  const v1 = Vector(3).init(.{ 3, 4, 5 });
  const v2 = Vector(3).init(.{ 6, 7, 8 });
  expectVectorEqual(3, Vector(3).init(.{ 18, 28, 40 }), v1.mul(v2));

  var v3 = Vector(3).init(.{ 1, 2, 3 });
  v3.mulAssign(Vector(3).init(.{ 3, 2, 1 }));
  expectVectorEqual(3, Vector(3).init(.{ 3, 4, 3 }), v3);
}

test "vector scalar multiplication" {
  const v1 = Vector(3).init(.{ 3, 4, 5 });
  expectVectorEqual(3, Vector(3).init(.{ 6, 8, 10 }), v1.mulScalar(2));

  var v3 = Vector(3).init(.{ 1, 2, 3 });
  v3.mulAssignScalar(3);
  expectVectorEqual(3, Vector(3).init(.{ 3, 6, 9 }), v3);
}

test "vector division" {
  const v1 = Vector(3).init(.{ 10, 20, 30 });
  const v2 = Vector(3).init(.{ 5, 2, 6 });
  expectVectorEqual(3, Vector(3).init(.{ 2, 10, 5 }), v1.div(v2));

  var v3 = Vector(3).init(.{ 3, 2, 6 });
  v3.divAssign(Vector(3).init(.{ 1, 2, 3 }));
  expectVectorEqual(3, Vector(3).init(.{ 3, 1, 2 }), v3);
}

test "vector scalar division" {
  const v1 = Vector(3).init(.{ 12, 24, 36 });
  expectVectorEqual(3, Vector(3).init(.{ 1, 2, 3 }), v1.divScalar(12));

  var v3 = Vector(3).init(.{ 1, 2, 3 });
  v3.divAssignScalar(1);
  expectVectorEqual(3, Vector(3).init(.{ 1, 2, 3 }), v3);
}

test "vector dot product" {
  const v1 = Vector(3).init(.{ 1, 2, 3 });
  const v2 = Vector(3).init(.{ 4, 5, 6 });
  std.testing.expectEqual(@floatCast(f32, 32), v1.dot(v2));
}

test "vector norm squared" {
  const v1 = Vector(2).init(.{ 3, 4 });
  std.testing.expectEqual(@floatCast(f32, 25), v1.normSquared());
}

test "vector norm" {
  const v1 = Vector(2).init(.{ 3, 4 });
  std.testing.expectEqual(@floatCast(f32, 5), v1.norm());
}

test "vector normalization" {
  const v1 = Vector(3).init(.{ 30, 10, 20 });
  expectVectorEqual(3, Vector(3).init(.{0.80178372573729, 0.26726124191243, 0.53452248382486}), v1.normalize());

  var v2 = Vector(3).init(.{ 60, 20, 40 });
  v2.normalizeAssign();
  expectVectorEqual(3, Vector(3).init(.{0.80178372573729, 0.26726124191243, 0.53452248382486}), v2);
}

test "vector cross product" {
  const v1 = Vector(3).init(.{ 4, 5, 6 });
  const v2 = Vector(3).init(.{ 7, 8, 9 });
  expectVectorEqual(3, Vector(3).init(.{ -3, 6, -3 }), v1.cross(v2));
}
