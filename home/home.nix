{ pkgs, ... }:
{
  home.stateVersion = "25.05";
  home.packages = with pkgs; [
    meslo-lgs-nf
    zotero
    texliveFull
    obsidian
    pdftk
    texstudio
    biber
    pandoc
    liberation_ttf
    cups-pdf-to-pdf
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
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ./config/powerlevel10k_rainbow.omp.json);
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Seijji";
        email = "fondly.possum@pm.me";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.kitty = {
    enable = true;
    themeFile = "GitHub_Dark";
    enableGitIntegration = true;
    font = {
      name = "MesloLGS NF";
      size = 10;
    };
    settings = {
      window_padding_width = 10;
      background_opacity = "0.90";
      scrollback_lines = 10000;
    };
  };
}
