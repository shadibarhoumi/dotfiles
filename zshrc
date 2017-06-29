# >>>>> zshrc <<<<<
#Authors: Danny An and Rafael Cosman

# if [ "$TMUX" = "" ]; then tmux; fi



# Oh-my-zsh configuration
################################################################################
echo "Loading oh-my-zsh..."
export ZSH=$HOME/.oh-my-zsh

# use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# choose how often to auto-update (in days).
export UPDATE_ZSH_DAYS=12

# enable command auto-correction.
ENABLE_CORRECTION="true"

# display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# load plugins. (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew git git-extra autojump vi-mode)

# Set the zsh theme
ZSH_THEME="kolo"

# Run oh-my-zsh
source $ZSH/oh-my-zsh.sh

unsetopt correct_all

# Prompt configuration
################################################################################
echo "Setting up the prompt..."

autoload -Uz promptinit
promptinit

setopt histignorealldups sharehistory

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

echo "Enabling modern completion system..."
autoload -Uz compinit
compinit


zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
# eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Run this on Ubuntu to change your capslock to backspace
# setxkbmap -option caps:backspace

# Install our custom snippet system
################################################################################
echo "Installing snippets..."

setopt extendedglob

typeset -Ag abbreviations
abbreviations=()

just_alias() {
  alias $1="$2"
}

just_expansion() {
  if [[ "$2" == *\^* ]]
  then
    abbreviations[$1]="$2"
  else
    abbreviations[$1]="$2 ^"
  fi
}

snippet() {
  just_alias $1 $2
  just_expansion $1 $2
}

als() {
  snippet $1 $2
  echo "snippet '$1' '$2'" >> ~/code/dotfiles/zsh_snippets.zsh
}

source ~/code/dotfiles/zsh_snippets.zsh

magic-abbrev-expand() {
    local MATCH
    TEMP="$LBUFFER"
    SNIPPET=${abbreviations[$LBUFFER]}

    if [[ -n "$SNIPPET" ]]
    then
      LBUFFER=${SNIPPET[(ws:^:)1]}
      RBUFFER=${SNIPPET[(ws:^:)2]}
    else
      zle self-insert
    fi

}

no-magic-abbrev-expand() {
  LBUFFER+=' '
}



zle -N magic-abbrev-expand
zle -N no-magic-abbrev-expand
bindkey " " magic-abbrev-expand
bindkey "^x " no-magic-abbrev-expand
#bindkey -M isearch " " self-insert


gd2() {
  git diff --color=always | \
    gawk '{bare=$0;gsub("\033[[][0-9]*m","",bare)};\
      match(bare,"^@@ -([0-9]+),[0-9]+ [+]([0-9]+),[0-9]+ @@",a){left=a[1];right=a[2];next};\
      bare ~ /^(---|\+\+\+|[^-+ ])/{print;next};\
      {line=gensub("^(\033[[][0-9]*m)?(.)","\\2\\1",1,$0)};\
      bare~/^-/{print "-"left++ ":" line;next};\
      bare~/^[+]/{print "+"right++ ":" line;next};\
      {print "("left++","right++"):"line;next}'
}

# Percol https://github.com/mooz/percol
function exists { which $1 &> /dev/null }

if exists percol; then
    function percol_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }

    zle -N percol_select_history
    bindkey '^R' percol_select_history
fi

