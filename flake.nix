{
  description = "Collection of tools for processing CityJSON";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    val3dity-src = {
      url = "github:tudelft3d/val3dity/2.6.0";
      flake = false;
    };

    cjseq-src = {
      url = "github:cityjson/cjseq/0.3.1";
      flake = false;
    };

    cjio-src = {
      url = "github:cityjson/cjio/v0.10.1";
      flake = false;
    };

    cjval-src = {
      url = "github:cityjson/cjval/0.9.0";
      flake = false;
    };

    flatcitybuf-src = {
      url = "github:cityjson/flatcitybuf/v0.7.4";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, val3dity-src, cjseq-src, cjio-src, cjval-src, flatcitybuf-src }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      packagesFor = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          val3dity = pkgs.stdenv.mkDerivation {
            pname = "val3dity";
            version = "2.6.3";
            src = val3dity-src;

            nativeBuildInputs = with pkgs; [ cmake ninja ];
            buildInputs = with pkgs; [
              cgal gmp mpfr eigen
              geos
              spdlog
              pugixml
              tclap
              boost
              nlohmann_json
            ];

            cmakeFlags = [ "-DVAL3DITY_USE_INTERNAL_DEPS=OFF" "-G Ninja" ];
          };

          cjseq = pkgs.rustPlatform.buildRustPackage {
            pname = "cjseq";
            version = "0.3.1";
            src = cjseq-src;
            cargoLock.lockFile = ./cjseq-Cargo.lock;
            postPatch = ''
              cp ${./cjseq-Cargo.lock} Cargo.lock
            '';
          };

          cjio = pkgs.python3.pkgs.buildPythonPackage {
            pname = "cjio";
            version = "0.10.1";
            src = cjio-src;
            format = "setuptools";

            propagatedBuildInputs = with pkgs.python3.pkgs; [
              numpy
              click
            ];
          };

          cjval = pkgs.rustPlatform.buildRustPackage {
            pname = "cjval";
            version = "0.9.0";
            src = cjval-src;
            cargoLock.lockFile = ./cjval-Cargo.lock;
            postPatch = ''
              cp ${./cjval-Cargo.lock} Cargo.lock
            '';
            cargoBuildFlags = [ "--features" "build-binary" ];
            cargoTestFlags = [ "--lib" "--bins" "--tests" ];
          };

          flatcitybuf = pkgs.rustPlatform.buildRustPackage {
            pname = "flatcitybuf";
            version = "0.7.4";
            src = flatcitybuf-src;
            sourceRoot = "source/src/rust";
            cargoLock.lockFile = ./flatcitybuf-Cargo.lock;
            postPatch = ''
              cp ${./flatcitybuf-Cargo.lock} Cargo.lock
            '';
            cargoBuildFlags = [ "--package" "fcb_cli" ];
            cargoTestFlags = [ "--package" "fcb_cli" ];
          };
        };
    in
    {
      packages = forAllSystems packagesFor;

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          p = packagesFor system;
        in
        {
          default = pkgs.mkShell {
            packages = builtins.attrValues p;

            shellHook = ''
              echo ""
              echo "3dgeo dev shell"
              echo "---------------"
              echo "$(cjio --version 2>&1 | head -1)"
              echo "$(cjseq --version 2>&1 | head -1)"
              echo "$(cjval --version 2>&1 | head -1)"
              echo "$(fcb --version 2>&1 | head -1)"
              echo "$(val3dity --version 2>&1 | grep -v '^[[:space:]]*$' | head -1)"
              echo ""
            '';
          };
        });
    };
}
