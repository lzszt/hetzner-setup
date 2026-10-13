{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          default = self.packages.${system}.hetzner-setup;
          hetzner-setup = import ./hetzner-setup.nix { inherit pkgs; };
          hetzner-setup-completions = import ./completions.nix { inherit pkgs; };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.hcloud
            self.packages.${system}.hetzner-setup
          ];
        };
      }
    );
}
