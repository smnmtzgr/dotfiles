# dotfiles

Reproduzierbares Setup für Agentic Engineering unter **WSL2 / Ubuntu**, verwaltet mit Nix und
Home Manager (standalone, ohne NixOS).

Inspiriert von [kunchenguid/dotfiles](https://github.com/kunchenguid/dotfiles) und dem Video
[L8 Principal's Agentic Dev Environment From Scratch](https://youtu.be/5N-okeDdIuI), portiert von
macOS/nix-darwin auf WSL/Linux.

## Installation auf einer neuen Maschine

```sh
# 1. Nix installieren (Determinate Systems)
curl -fsSL https://install.determinate.systems/nix | sh -s -- install

# 2. Repo klonen - der Pfad ist wichtig, home.nix verweist darauf
git clone https://github.com/smnmtzgr/dotfiles ~/code/dotfiles

# 3. Anwenden
cd ~/code/dotfiles && ./rebuild.sh
```

Beim ersten Lauf muss `home-manager` selbst noch vorhanden sein:

```sh
nix run home-manager/master -- switch --flake ~/code/dotfiles#simon
```

## Alltag

| | |
|---|---|
| `./rebuild.sh` (oder Alias `hm`) | Änderungen an `home.nix` / `flake.nix` anwenden |
| `nix flake update` | Alle Inputs aktualisieren |
| `nix flake check --no-build` | Config prüfen, ohne etwas zu ändern |

Alles unter `home/` ist per `mkOutOfStoreSymlink` **live** ins Repo verlinkt: nvim-, WezTerm-,
herdr- und Claude-Configs wirken sofort nach dem Speichern, ohne Rebuild. Nur `home.nix` und
`flake.nix` brauchen `./rebuild.sh`.

## Struktur

```
flake.nix     Inputs (nixpkgs, home-manager, herdr) und homeConfigurations."simon"
home.nix      Pakete, zsh, git, starship, Symlinks
rebuild.sh    home-manager switch
home/
  AGENTS.md              -> ~/.claude/CLAUDE.md und ~/.codex/AGENTS.md
  .claude/               settings.json, statusline-command.sh
  .config/nvim/          lazy.nvim, rose-pine, oil, snacks, neogit
  .config/wezterm/       wird von Windows aus geladen, siehe unten
  .config/herdr/         Keybindings für den Multiplexer
```

## WezTerm unter Windows

WezTerm läuft als Windows-Prozess und kann keine WSL-Pfade als Config lesen. Die echte Config
liegt trotzdem hier im Repo; auf der Windows-Seite steht nur ein Stub in
`C:\Users\<user>\.wezterm.lua`:

```lua
return dofile('\\\\wsl.localhost\\Ubuntu\\home\\simon\\code\\dotfiles\\home\\.config\\wezterm\\wezterm.lua')
```

Zusätzlich muss die **Hack Nerd Font unter Windows** installiert sein
([nerdfonts.com](https://www.nerdfonts.com/font-downloads)) - `fonts.fontconfig` in der WSL
betrifft nur Linux-Anwendungen, nicht den Windows-Renderer von WezTerm.

## Make it yours

Wer das forkt, ändert mindestens:

- `home.username` / `home.homeDirectory` in `home.nix` und den Attributnamen
  `homeConfigurations."simon"` in `flake.nix` (auch in `rebuild.sh`)
- `programs.git.settings.user.*` in `home.nix` - sonst committet man unter fremder Identität
- den WSL-Pfad im WezTerm-Stub oben
- `home/AGENTS.md` - das sind meine persönlichen Agent-Anweisungen, sie werden sonst still
  von Claude Code und Codex übernommen

## Nicht in diesem Repo

Die Toolchain für [firstmate](https://github.com/kunchenguid/firstmate) (`no-mistakes`,
`treehouse`, `gh-axi`, `lavish-axi`, `tasks-axi`, `quota-axi`, `chrome-devtools-axi`) wird
bewusst **nicht** über Nix verwaltet. firstmate verlangt jeweils die neueste veröffentlichte
Version und meldet ältere beim Session-Start als fehlend; ein Nix-Pin würde permanent dagegen
arbeiten. Diese Tools installiert firstmates eigener Bootstrap nach `~/.npm-global`.
