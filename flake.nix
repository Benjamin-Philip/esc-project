{
  description = "Flake to build the ESC Project";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-old,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-old = nixpkgs-old.legacyPackages.${system};
      fonts = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };

      vcdvcd = pkgs.python3Packages.buildPythonPackage rec {
        pname = "vcdvcd";
        version = "2.6.0";
        pyproject = true;
        src = pkgs.fetchPypi {
          inherit pname version;
          sha256 = "sha256-ltjOSRcp6MitcDSlCTYBQJ2KP0o0Aj0L49soZQ7LsSg=";
        };
        nativeBuildInputs = with pkgs.python3Packages; [ setuptools ];
      };

      vcd2wavedrom = pkgs.python3Packages.buildPythonPackage {
        pname = "vcd2wavedrom";
        version = "0.0.0";
        pyproject = true;
        src = pkgs.fetchFromGitHub {
          owner = "Toroid-io";
          repo = "vcd2wavedrom";
          rev = "main";
          sha256 = "sha256-NOACQndUVOsvjapCp7XuE3oBkchq2f0xjkOx5dDzLvI=";
        };

        postPatch = ''
          substituteInPlace pyproject.toml --replace "2.3.2" "2.6.0"
        '';

        nativeBuildInputs = with pkgs.python3Packages; [
          flit-core
        ];

        propagatedBuildInputs = [
          vcdvcd
        ];
      };

      buildInputs =
        with pkgs;
        [
          # Typesetting
          pandoc
          texlive.combined.scheme-small
          librsvg

          # Waves
          iverilog
          python313Packages.cocotb
          gtkwave

          # RTL
          yosys
          netlistsvg

          # Misc
          gnumake
          gnused
          jq
        ]
        ++ [
          pkgs-old.nodePackages.wavedrom-cli
          vcd2wavedrom
        ];

    in

    rec {

      packages.x86_64-linux.report = pkgs.stdenv.mkDerivation {
        inherit buildInputs;

        name = "esc-project";
        src = ./.;
        phases = [
          "unpackPhase"
          "buildPhase"
        ];
        buildPhase = ''
          export FONTCONFIG_FILE=${fonts}
          export HOME=$(mktemp -d)
          export TEXMFVAR=$(mktemp -d)
          make
          cp -r ./out $out
        '';
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.report;

      devShells.default = pkgs.mkShell {
        inherit buildInputs;
      };
    };
}
