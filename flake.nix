{
  description = "My blog";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self,
              nixpkgs,
              flake-utils } :
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      formatter = pkgs.nixpkgs-fmt;

      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          gnumake
          quarto
          # Haskell
          cabal-install
          haskell-language-server
          ghc
          # Latex/tikz
          texliveFull
        ];
      };
    });
}

