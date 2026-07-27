# Troubleshooting

## Icons render as boxes

Install and select a Nerd Font (FiraCode Nerd Font, JetBrainsMono Nerd Font, Hack Nerd Font, etc.), then restart the terminal.

## Starship style or color does not change

Check preference files:

```fish
cat ~/.config/starship/style
cat ~/.config/starship/color
```

Apply:

```fish
dot-files --edit style
# or pick a color palette:
dot-files --color moonlight
dot-files --color catppuccin-macchiato
dot-files --color catppuccin-mocha
```

## Fastfetch welcome still shows the wrong name

Edit `~/.config/starship/username` or run:

```fish
dot-files --username "Your Name"
dot-files --username reset
fastfetch-apply-welcome
```

Open a new Fish session to see the startup banner update.

## Time is not on the right

Starship `right_format` needs enough terminal width. Widen the terminal or simplify the left prompt.

## Fastfetch Dev Tools missing Node.js or pnpm

`zz-fastfetch.fish` loads late so version managers can initialize first. Ensure your version manager loads before `zz-fastfetch.fish` in `conf.d/`.

## Existing files were replaced

Restore from:

```text
~/.dotfiles-backup/<timestamp>/
```
