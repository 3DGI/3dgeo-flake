{
  description = "Tyler packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    tyler-src = {
      url = "git+https://github.com/3DGI/tyler?rev=9085570d7e9ca4e15c1cdcc7b46ac7d01524d0f1&submodules=1";
      flake = false;
    };

    tyler-multiformat-src = {
      url = "git+https://github.com/3DGI/tyler?ref=multi-format-output&rev=e7b5e6d699f1b8b1652181b8d0332d862cadc14a&submodules=1";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, tyler-src, tyler-multiformat-src, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          mkTyler =
            {
              pname,
              version,
              src,
              executable,
              skippedTests,
            }:
            pkgs.rustPlatform.buildRustPackage {
              inherit pname version src;

              cargoLock.lockFile = "${src}/Cargo.lock";

              nativeBuildInputs = with pkgs; [
                pkg-config
                rustPlatform.bindgenHook
                makeWrapper
              ];

              buildInputs = [ pkgs.proj ];

              # These upstream tests either require files absent from the
              # repository or assert ordering that differs from the code.
              # Keep the rest of each revision's test suite enabled.
              checkFlags = pkgs.lib.concatMap (test: [
                "--skip"
                test
              ]) skippedTests;

              postInstall = ''
                mkdir -p "$out/share/${pname}"
                cp -r resources/* "$out/share/${pname}/"

                wrapProgram "$out/bin/${executable}" \
                  --set-default PROJ_DATA "${pkgs.proj}/share/proj" \
                  --set-default TYLER_RESOURCES_DIR "$out/share/${pname}"
              '';

              meta = {
                description = "Create tiles from 3D city objects encoded as CityJSONFeatures";
                homepage = "https://github.com/3DGI/tyler";
                license = pkgs.lib.licenses.asl20;
                mainProgram = executable;
                platforms = pkgs.lib.platforms.unix;
              };
            };

          tyler-legacy = mkTyler {
            pname = "tyler-legacy";
            version = "0.3.14";
            src = tyler-src;
            executable = "tyler";
            skippedTests = [
              "cli::tests::verify_object_types"
              "formats::cesium3dtiles::tests::test_implicittiling"
              "spatial_structs::tests::test_intersect_bbox"
              "spatial_structs::tests::test_morton_encode_rd"
            ];
          };

          tyler-legacy-multiformat = mkTyler {
            pname = "tyler-legacy-multiformat";
            version = "0.4.0-alpha10-e7b5e6d";
            src = tyler-multiformat-src;
            executable = "tyler-multiformat";
            skippedTests = [
              "cli::tests::verify_object_types"
              "formats::cesium3dtiles::tests::test_implicittiling"
              "spatial_structs::tests::test_morton_encode_rd"
            ];
          };
        in
        {
          default = tyler-legacy;
          inherit tyler-legacy tyler-legacy-multiformat;
        }
      );
    };
}
