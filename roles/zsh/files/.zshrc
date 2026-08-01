#!/usr/bin/env zsh

# Homebrew provides the current shell's package environment on macOS.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Some SSH hosts do not have Ghostty's terminfo entry. Preserve it when the
# host supports it, otherwise use the broadly available xterm definition.
if [[ -n ${SSH_CONNECTION:-} && $TERM == xterm-ghostty ]]; then
  if (( ! $+commands[infocmp] )) || ! infocmp "$TERM" &>/dev/null; then
    export TERM=xterm-256color
  fi
fi

# Zinit manages only shell plugins. It is installed by the zinit Ansible role;
# leaving this conditional keeps a new or remote shell usable during setup.
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ -r "$ZINIT_HOME/zinit.zsh" ]]; then
  source "$ZINIT_HOME/zinit.zsh"

  # Completion definitions must be loaded before compinit.
  zinit light zsh-users/zsh-completions
  autoload -U +X bashcompinit && bashcompinit
  autoload -Uz compinit && compinit
  zinit cdreplay -q

  zinit light zsh-users/zsh-autosuggestions
  # Keep syntax highlighting last so it can observe the final command line.
  zinit light zsh-users/zsh-syntax-highlighting
else
  autoload -U +X bashcompinit && bashcompinit
  autoload -Uz compinit && compinit
fi

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
# zsh-autosuggestions wraps this widget to accept a suggestion one word at a time.
bindkey '^y' forward-word
bindkey '^[w' kill-region
bindkey '^[[3~' delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line

# History
HISTSIZE=10000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no

# Load the small, reviewed modules deployed to ~/.config/zsh.
for file in "$HOME"/.config/zsh/*.zsh(N); do
  source "$file"
done

[[ -r "$HOME/.raftrc" ]] && source "$HOME/.raftrc"

# Starship is optional until its role has been deployed.
if (( $+commands[starship] )); then
  export STARSHIP_LOG=error
  eval "$(starship init zsh)"
fi
