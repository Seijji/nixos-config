# modules/fonts.nix
{pkgs, ...}:
{
  fonts.fontDir.enable = true;
  fonts = {
    fontconfig = {
      enable = true;
    };
    packages = with pkgs; [
      nerd-fonts._0xproto # personal fav monospaced font. However, you can use whatever monospaced nerd font you'd like.
      nerd-fonts.symbols-only
      nerd-fonts.noto
      nerd-fonts.hack
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
      fira-sans
      font-awesome
      roboto
      jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      material-symbols
      material-icons
      corefonts
    ];
  };
}
