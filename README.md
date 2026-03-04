# 3dgeo-flake

Nix flake packaging [CityJSON](https://www.cityjson.org/) tools:

| Package | Description |
|---|---|
| [`val3dity`](https://github.com/tudelft3d/val3dity) | Validate 3D city models |
| [`cjval`](https://github.com/cityjson/cjval) | Validate CityJSON files and extensions |
| [`cjseq`](https://github.com/cityjson/cjseq) | Process CityJSONSeq streams |
| [`cjio`](https://github.com/cityjson/cjio) | CityJSON I/O and manipulation (Python) |
| [`flatcitybuf`](https://github.com/cityjson/flatcitybuf) | FlatBuffers-based CityJSON format |

## Use the dev shell

Drop into a shell with all tools on `PATH`:

```sh
nix develop github:3DGI/3dgeo-flake
```

Or add a `shell.nix` / `flake.nix` to your project (see below).

## Build a single tool

```sh
nix build github:3DGI/3dgeo-flake#cjval
./result/bin/cjval --help
```

## Integrate into your own flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    geodev.url = "github:3DGI/3dgeo-flake";
  };

  outputs = { nixpkgs, geodev, ... }:
    let
      system = "aarch64-darwin"; # adjust as needed
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        # merge all 3dgeo tools into your shell; adds them to 'packages'
        inputsFrom = [ geodev.devShells.${system}.default ];

        # add your own packages alongside
        packages = with pkgs; [ gdal ];
      };
    };
}
```

To use individual packages instead of the whole devshell:

```nix
packages = [
  geodev.packages.${system}.cjval
  geodev.packages.${system}.cjseq
];
```
