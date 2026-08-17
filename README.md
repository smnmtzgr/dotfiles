# dotfiles

Reproducible agentic-engineering setup for **WSL2 / Ubuntu**, managed with Nix and Home Manager
(standalone, no NixOS).

Inspired by [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) and the video
[L8 Principal's Agentic Dev Environment From Scratch](https://youtu.be/5N-okeDdIuI), ported from
macOS/nix-darwin to WSL/Linux.

## Installing on a new machine

```sh
# 1. Install Nix (Determinate Systems)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. Clone - the path matters, home.nix points at it
git clone https://github.com/smnmtzgr/dotfiles ~/code/dotfiles

# 3. Apply
cd ~/code/dotfiles && ./rebuild.sh
```

On the very first run `home-manager` isn't installed yet, so bootstrap it once:

```sh
nix run home-manager/master -- switch --flake ~/code/dotfiles#simon
```

## Day to day

| | |
|---|---|
| `./rebuild.sh` (or the `hm` alias) | Apply changes to `home.nix` / `flake.nix` |
| `hmu` | Update all flake inputs, then apply |
| `hmu herdr` | Update a single input, then apply |
| `nix flake check --no-build` | Validate without changing anything |
| `home-manager generations` | List generations; roll back with `<path>/activate` |
| `home-manager news --flake .#simon` | Read release notes for the modules in use |

Note that there is no `~/.config/home-manager/` - the configuration lives here instead. Any
`home-manager` subcommand therefore needs `--flake ~/code/dotfiles#simon`, otherwise it reports
"No configuration file found". `rebuild.sh` and the `hm` / `hmu` helpers pass it for you.

Everything under `home/` is symlinked **live** into this repo via `mkOutOfStoreSymlink`: the nvim,
WezTerm, herdr and Claude configs take effect the moment you save, no rebuild needed. Only
`home.nix` and `flake.nix` require `./rebuild.sh`.

## Layout

```
flake.nix     Inputs (nixpkgs, home-manager, herdr) and homeConfigurations."simon"
home.nix      Packages, zsh, git, starship, symlinks
rebuild.sh    home-manager switch
docs/         Printable keybinding reference (German)
home/
  AGENTS.md              -> ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
  .claude/               settings.json, statusline-command.sh
  .config/nvim/          lazy.nvim, rose-pine, oil, snacks, neogit
  .config/wezterm/       loaded from the Windows side, see below
  .config/herdr/         keybindings for the multiplexer
```

## WezTerm on Windows

WezTerm runs as a Windows process and cannot read a WSL path as its config. The real config still
lives here in the repo; the Windows side only holds a stub at `C:\Users\<user>\.wezterm.lua`:

```lua
return dofile('\\\\wsl.localhost\\Ubuntu\\home\\simon\\code\\dotfiles\\home\\.config\\wezterm\\wezterm.lua')
```

Two consequences worth knowing:

- **WezTerm's config auto-reload does not fire** for a file pulled in via `dofile()` over UNC.
  After editing, press `Ctrl+Shift+R` or restart WezTerm.
- The **Hack Nerd Font must be installed on Windows**
  ([nerdfonts.com](https://www.nerdfonts.com/font-downloads)). `fonts.fontconfig` in WSL only
  covers Linux applications, not WezTerm's Windows renderer.

Getting a new tab to open in the WSL home directory takes three separate settings, because WezTerm
resolves three different paths: `wsl_domains.default_cwd` (Linux path), `config.default_cwd` (UNC
path), and OSC 7 emitted from zsh so WezTerm can know a pane's directory at all.

## Make it yours

If you fork this, change at least:

- `home.username` / `home.homeDirectory` in `home.nix`, and the attribute name
  `homeConfigurations."simon"` in `flake.nix` (referenced by `rebuild.sh` too)
- `programs.git.settings.user.*` in `home.nix` - otherwise you commit under someone else's identity
- the WSL path in the WezTerm stub above
- `home/AGENTS.md` - those are my personal agent instructions, and they are picked up silently by
  Claude Code and Codex

## Deliberately not in this repo

The toolchain for [firstmate](https://github.com/kunchenguid/firstmate) (`no-mistakes`,
`treehouse`, `gh-axi`, `lavish-axi`, `tasks-axi`, `quota-axi`, `chrome-devtools-axi`) is **not**
managed through Nix. firstmate requires the latest published version of each and reports older ones
as missing on every session start, so a Nix pin would permanently fight its bootstrap. Those tools
are installed imperatively into `~/.npm-global/bin` and `~/.local/bin` instead.
