{ pkgs, ... }:
{
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    meslo-lgs-nf
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    initContent = ''
      HISTFILE=~/.histfile
      HISTSIZE=1000
      SAVEHIST=10000
      setopt extendedglob
      unsetopt autocd nomatch

      eval "$(direnv hook zsh)"
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config/powerlevel10k_rainbow.omp.json);
  };
}
