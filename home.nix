{ config, pkgs, inputs, ... }:

let
  # The repo lives directly at ~/code/dotfiles - no symlink indirection.
  dotfiles = "${config.home.homeDirectory}/code/dotfiles";
in

{
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # Do not change, not even when updating Home Manager.
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

    # Node from Nix rather than apt - the AXI tools are installed globally through it.
    pkgs.nodejs_24

    # Browser for chrome-devtools-axi. WSL has none otherwise.
    pkgs.chromium

    pkgs.bat
    pkgs.eza
    pkgs.zoxide

    # Herdr from the flake input
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Home Manager's manpage generation pulls the nixpkgs path into a derivation
  # without a store context, which makes every rebuild print a warning. We read
  # the options online anyway, so the manpage is not worth the noise.
  manual.manpages.enable = false;

  fonts.fontconfig.enable = true;

  # Everything under home/ is symlinked live back into the repo: editing a file
  # there takes effect immediately, no rebuild. Only home.nix and flake.nix
  # require ./rebuild.sh.
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
  # One source of truth for every agent harness.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  home.sessionVariables = {
    EDITOR = "nvim";
    # Move the npm prefix out of /usr/local, otherwise `npm i -g` needs sudo
    # and firstmate's bootstrap fails.
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
    # Point chrome-devtools-axi at the Nix chromium instead of chrome.exe.
    CHROME_PATH = "${pkgs.chromium}/bin/chromium";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    # treehouse and no-mistakes - placed here by firstmate's installers.
    "${config.home.homeDirectory}/.local/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # OSC 7 reports the current directory to the terminal. Without it WezTerm
    # cannot determine a pane's directory, so a new tab does not open where you are.
    initContent = ''
      _osc7_cwd() {
        printf '\033]7;file://%s%s\033\\' "''${HOST}" "''${PWD}"
      }
      autoload -Uz add-zsh-hook
      add-zsh-hook chpwd _osc7_cwd
      _osc7_cwd

      # hmu = home-manager update. Without an argument it updates every flake
      # input, with one it updates just that input (e.g. `hmu herdr`) - hence a
      # function rather than an alias. The cd runs in a subshell so the calling
      # shell stays where it is.
      hmu() {
        ( cd ~/code/dotfiles && nix flake update "$@" ) && ~/code/dotfiles/rebuild.sh
      }
    '';
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
      # gh as the credential helper for HTTPS remotes. It has to live here
      # because `gh auth setup-git` would write into the Nix-managed, read-only
      # gitconfig.
      credential."https://github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
      credential."https://gist.github.com".helper = "!${pkgs.gh}/bin/gh auth git-credential";
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
