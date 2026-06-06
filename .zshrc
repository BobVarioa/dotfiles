# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:~/.local/bin:/usr/local/go/bin:/home/bob/go/bin:/home/bob/.local/share/gem/ruby/3.4.0/bin:/home/bob/.cargo/bin:/home/bob/flutter/bin/:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/usr/share/oh-my-zsh/
export ZSH_CUSTOM=/usr/share/zsh/

powerline-daemon -q
. /usr/share/powerline/bindings/zsh/powerline.zsh

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"
SPROMPT="zsh: correct '%R' to '%r' [Ny]?"

plugins=(git kate github gradle node npm debian aliases zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export EDITOR=micro

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/aliases.zsh

# bun completions
[ -s "/home/bob/.bun/_bun" ] && source "/home/bob/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# fzf
# Set up fzf key bindings and fuzzy completion
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND="ls -a --icons=always"
export FZF_DEFAULT_OPTS="--ansi"

export RUSTC_WRAPPER=sccache
export JAVA_HOME=/usr/lib/jvm/default-runtime/

PATH="/home/bob/perl5/bin:/home/bob/.local/bin:$PATH"; export PATH;
PERL5LIB="/home/bob/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/bob/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/bob/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/bob/perl5"; export PERL_MM_OPT;

source /usr/share/nvm/init-nvm.sh
