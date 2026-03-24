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

## Add to your nix profile
Add individual tools like:
```sh
nix profile add --refresh github:3DGI/3dgeo-flake#packages.x86_64-linux.flatcitybuf
```
Where the last part (<platform>.<package>) is one of:

```
└───packages
    ├───aarch64-darwin
    │   ├───cjio: package 'python3.13-cjio-0.10.1'
    │   ├───cjseq: package 'cjseq-0.3.1'
    │   ├───cjval: package 'cjval-0.8.4'
    │   ├───flatcitybuf: package 'flatcitybuf-0.7.4'
    │   └───val3dity: package 'val3dity-2.6.3'
    ├───aarch64-linux
    │   ├───cjio: package 'python3.13-cjio-0.10.1'
    │   ├───cjseq: package 'cjseq-0.3.1'
    │   ├───cjval: package 'cjval-0.8.4'
    │   ├───flatcitybuf: package 'flatcitybuf-0.7.4'
    │   └───val3dity: package 'val3dity-2.6.3'
    ├───x86_64-darwin
    │   ├───cjio: package 'python3.13-cjio-0.10.1'
    │   ├───cjseq: package 'cjseq-0.3.1'
    │   ├───cjval: package 'cjval-0.8.4'
    │   ├───flatcitybuf: package 'flatcitybuf-0.7.4'
    │   └───val3dity: package 'val3dity-2.6.3'
    └───x86_64-linux
        ├───cjio: package 'python3.13-cjio-0.10.1'
        ├───cjseq: package 'cjseq-0.3.1'
        ├───cjval: package 'cjval-0.8.4'
        ├───flatcitybuf: package 'flatcitybuf-0.7.4'
        └───val3dity: package 'val3dity-2.6.3'
```

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
