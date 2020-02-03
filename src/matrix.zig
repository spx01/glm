const std = @import("std");
const math = std.math;
const testing = std.testing;

pub fn Matrix(comptime N: usize) type {
  return packed struct {
    const Self = @This();
    pub const Scalar = f32;

    values: [N][N]Scalar,

    /// Initialies a matrix.
    pub fn init(values: [N][N]Scalar) Self {
      return .{ .values = values };
    }

    /// Creates a matrix filled with the given value.
    pub fn filled(n: Scalar) Self {
      var result: Self = undefined;

      comptime var i = 0;
      inline while (i < N) : (i += 1) {
        comptime var j = 0;
        inline while (j < N) : (j += 1) {
          result.values[i][j] = n;
        }
      }

      return result;
    }

    /// A zero initialized matrix.
    pub const ZERO: Self = comptime Self.filled(0);

    /// An identity initialized matrix.
    pub const IDENTITY: Self = comptime brk: {
      var result: Self = undefined;

      comptime var i = 0;
      while (i < N) : (i += 1) {
        comptime var j = 0;
        while (j < N) : (j += 1) {
          result.values[i][j] = brk: {
            if (i == j) {
              break :brk 1;
            } else {
              break :brk 0;
            }
          };
        }
      }

      break :brk result;
    };

    /// Transposes this matrix
    pub fn transpose(self: Self) Self {
      var result: Self = undefined;

      comptime var i = 0;
      inline while (i < N) : (i += 1) {
        comptime var j = 0;
        inline while (j < N) : (j += 1) {
          result.values[j][i] = self.values[i][j];
        }
      }

      return result;
    }

    /// Multiplies 2 matrices together.
    pub fn mul(self: Self, other: Self) Self {
      var result: Self = undefined;

      const a = self.transpose();
      const b = other;

      comptime var i = 0;
      inline while (i < N) : (i += 1) {
        comptime var j = 0;
        inline while (j < N) : (j += 1) {
          const row: @Vector(N, Scalar) = a.values[j];
          const column: @Vector(N, Scalar) = b.values[i];
          const products: [N]Scalar = row * column;

          var sum = @floatCast(f32, 0);
          comptime var k = 0;
          inline while (k < N) : (k += 1) {
            sum += products[k];
          }

          result.values[i][j] = sum;
        }
      }

      return result;
    }
  };
}

fn expectMatrixEqual(comptime N: usize, expected: [N][N]f32, actual: Matrix(N)) void {
  comptime var i = 0;
  inline while (i < N) : (i += 1) {
    comptime var j = 0;
    inline while (j < N) : (j += 1) {
      testing.expectEqual(expected[i][j], actual.values[i][j]);
    }
  }
}

test "matrix initialization" {
  const A = Matrix(2).init(.{ .{ 1, 2 }, .{ 3, 4 } });
  expectMatrixEqual(2, [2][2]f32{ .{ 1, 2, }, .{ 3, 4 } }, A);
}

test "matrix zero" {
  expectMatrixEqual(3, Matrix(3).filled(0).values, Matrix(3).ZERO);
}

test "matrix identity" {
  expectMatrixEqual(3, [3][3]f32{ .{ 1, 0, 0 }, .{ 0, 1 , 0 }, .{ 0, 0, 1 } }, Matrix(3).IDENTITY);
}

test "matrix transpose" {
  const actual = Matrix(3).init(.{ .{ 1, 2, 3 }, .{ 4, 5, 6 }, .{ 7, 8, 9 } });
  const expected = [3][3]f32{ .{ 1, 4, 7 }, .{  2, 5, 8 }, .{ 3, 6, 9 } };
  expectMatrixEqual(3, expected, actual.transpose());
}

test "matrix multiplication" {
  const A = Matrix(2).init(.{ .{ 1, 2 }, .{ 3, 4 } });
  const B = Matrix(2).init(.{ .{ 6, 7 }, .{ 8, 9 } });
  const expected = [2][2]f32{ .{ 27, 40 }, .{ 35, 52 } };
  expectMatrixEqual(2, expected, A.mul(B));
}
