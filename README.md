$$
\colorbox{#1a1a1a}{
\begin{aligned}
&\color{#ffffff}{\texttt{________  __________________       __________________________  __}} \\
&\color{#ffffff}{\texttt{  / ____/ / / / ____/ ___/ ___/      / ____/ ____/\_  __/ ____/ / / /}} \\
&\color{#ffffff}{\texttt{ / /   / /\_/ / \_\_/  \textbackslash\_\_ \textbackslash\textbackslash\_\_ \textbackslash\______/ /\_  / \_\_/   / / / /   / /\_/ / }} \\
&\color{#ffffff}{\texttt{/ /\_ \_\_/ \_\_  / /\_ \_\_ \_\_\_/ / \_\_/ /\_\_\_\_\_/ \_\_/ / /\_ \_\_  / / / /\_ \_\_/ \_\_  /  }} \\
&\color{#ffffff}{\texttt{\textbackslash\_\_\_\_/\_/\_ /\_/\_\_\_\_\_//\_\_\_\_/\_\_\_\_/     /\_/   /\_\_\_\_\_/ /\_/  \textbackslash\_\_\_\_/\_/\_ /\_/}}
\end{aligned}
}
$$

# ♞ chess — game review in your terminal

A pure-Bash CLI that pulls your recent games from **Chess.com** or **Lichess**, lets you pick one with `fzf`, and shows a Game Review: accuracy, average centipawn loss, inaccuracies / mistakes / blunders, key moments with the engine's better move, an eval sparkline, a full move list, and a step-through board.

No Python, no Node. Just `bash`, `curl`, `jq`, `fzf` — plus optional `stockfish`.

## Install

```bash
./install.sh            # → ~/.local/bin/chess
./install.sh --system   # → /usr/local/bin/chess (sudo)
./install.sh --uninstall
```

The installer checks dependencies and offers to install them (apt, dnf, pacman, zypper, apk).

Manual install:

```bash
sudo apt install curl jq fzf stockfish      # stockfish is optional
install -m 755 chess ~/.local/bin/chess     # make sure ~/.local/bin is on PATH
```

Requires Bash 4.3+.

## Usage

```bash
chess -u                          # interactive: pick platform, enter username
chess -u lichess DrNykterstein    # or set it directly
chess -u chess.com:hikaru
chess -a                          # browse & review your last 30 games
chess -a 100                      # …or the last 100
chess -f game.pgn                 # review any local PGN
chess -c                          # show config
chess --clear-cache
```

### Keys

| Where | Keys |
|---|---|
| Game list (fzf) | type to filter · `enter` review · `?` preview · `esc` quit |
| Review screen | `s` step through board · `m` move list · `o` open in browser · `b` back · `q` quit |
| Board | `←/→` or `h/l` move · `↑/↓` or `g/G` start/end · `n/N` next/prev mistake · `f` flip · `q` back |

## Where the analysis comes from

| Game | Evaluation source |
|---|---|
| Lichess game that was analysed on lichess.org (◆ in the list) | Lichess server analysis — counts match the site |
| Any other Lichess game, every Chess.com game, PGN files | Local Stockfish (if installed), cached in `~/.cache/chess-cli/eval` |
| No Stockfish | Moves, board viewer and Chess.com's own accuracy (if the game was reviewed there) |

Chess.com's public API doesn't expose move-by-move evaluations, so Stockfish is what makes blunder detection possible for Chess.com games.

Classification uses Lichess's method: a move is an **inaccuracy / mistake / blunder** when it drops the mover's win chance by ≥ 5 / 10 / 15 percentage points. Accuracy uses Lichess's published accuracy formula (volatility-weighted + harmonic mean), so numbers are close to Lichess's and in the same ballpark as Chess.com's (which uses a proprietary model).

## Config

`~/.config/chess-cli/config` (plain `key=value`):

```ini
platform=lichess
username=DrNykterstein
games=30           # default number of games for -a
depth=14           # Stockfish depth (higher = slower, more precise)
threads=2          # Stockfish threads
pieces=unicode     # or ascii if your font renders chess glyphs badly
engine=/usr/games/stockfish   # optional explicit engine path
```

`NO_COLOR=1` disables colours; `CHESS_ASCII=1` forces letter pieces.

## Notes

- Only standard chess is listed (Chess960 and other variants are skipped). Lichess "from position" games are supported.
- Chess.com archives are fetched month by month (newest first) until enough games are collected.
- Move legality, SAN parsing and SAN generation are done in Bash (0x88 board); this is verified against standard perft counts.
