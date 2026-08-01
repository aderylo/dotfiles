#!/usr/bin/env zsh

# Keep user-installed tools and this repository's helper script available.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.dotfiles/bin"
  $path
)
