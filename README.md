# Neovim configuration

This is my modest Neovim configuration.

It includes:

- LSP configuration with native completion
- file and text search with `fzf-lua`
- formatting with `conform.nvim`
- file browsing with `oil.nvim`

## Installation

The setup is intended for macOS and uses Homebrew and GNU Stow:

```sh
git clone https://github.com/EskelinenAntti/neovim-configuration.git
cd neovim-configuration
make
```

`make` installs dependencies listed in the `Brewfile` and stows the Neovim
configuration into `~/.config/nvim`.
