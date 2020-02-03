# Zig GLM

A GLM alternative for the zig programming language.

## Installation

Execute the following from your project root to install the library.  Note that
the `dependencies` can be replaced with any other directory.

```sh
mkdir -p dependencies
git submodules add https://github.com/ziglang-contrib/glm dependencies/glm
cd dependencies/glm
git checkout v1.0.0
cd ../..
```

Add the following to your `build.zig` (replacing `exe` with the actual build step that requires this library):

```zig
exe.addPackagePath("glm", "dependencies/glm/glm.zig");
```
