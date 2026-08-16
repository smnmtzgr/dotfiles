{ config, pkgs, inputs, ... }:

let
  # Das Repo liegt direkt unter ~/code/dotfiles - keine Symlink-Indirektion.
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
in

{
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # Nicht aendern, auch nicht beim Update von Home Manager.
  home.stateVersion = "25.11";

  home.packages = [
    pkgs.ripgrep
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.jq
    pkgs.lazygit
    pkgs.neovim
    pkgs.nerd-fonts.hack

    # Node aus Nix statt aus apt - die AXI-Tools werden hierueber global installiert.
    pkgs.nodejs_24

    # Browser fuer chrome-devtools-axi. In der WSL gibt es sonst keinen.
    pkgs.chromium

    pkgs.bat
    pkgs.eza
    pkgs.zoxide

    # Herdr aus dem Flake-Input installieren
    inputs.herdr.packages.${pkgs.system}.default
  ];

  fonts.fontconfig.enable = true;

  # Alles unter home/ wird live ins Repo zurueckverlinkt: Datei im Repo editieren
  # wirkt sofort, ohne rebuild. Nur home.nix/flake.nix brauchen ./rebuild.sh.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/statusline-command.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/statusline-command.sh";
  # Eine Quelle fuer alle Agent-Harnesses.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.sessionVariables = {
    EDITOR = "nvim";
    # npm-Prefix aus /usr/local herausholen, sonst braucht `npm i -g` sudo
    # und firstmates Bootstrap scheitert.
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
    # chrome-devtools-axi soll den Nix-Chromium nehmen, nicht chrome.exe.
    CHROME_PATH = "${pkgs.chromium}/bin/chromium";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    # treehouse und no-mistakes - von firstmates Installern hierher gelegt.
    "${config.home.homeDirectory}/.local/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      l = "ls -lah";
      hm = "${dotfiles}/rebuild.sh";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "smnmtzgr";
      user.email = "smnmtzgr@gmail.com";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[>](purple)";
        error_symbol = "[>](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  programs.zoxide.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
