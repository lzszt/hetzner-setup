{ pkgs, ... }:
let
  hcloud = pkgs.lib.getExe pkgs.hcloud;
  jq = pkgs.lib.getExe pkgs.jq;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "hetzner-setup-completions";
  version = "0.1.0";
  src = ./completions;

  installPhase = ''
    mkdir -p $out/share/fish/vendor_completions.d
    mkdir -p $out/share/bash-completion/completions
    mkdir -p $out/share/zsh/site-functions

    substitute hetzner-setup.fish $out/share/fish/vendor_completions.d/hetzner-setup.fish \
      --replace-fail "hcloud " "${hcloud} " \
      --replace-fail "jq " "${jq} "
    substitute hetzner-setup.bash $out/share/bash-completion/completions/hetzner-setup \
      --replace-fail "hcloud " "${hcloud} "
    substitute _hetzner-setup $out/share/zsh/site-functions/_hetzner-setup \
      --replace-fail "hcloud " "${hcloud} "
  '';
}
