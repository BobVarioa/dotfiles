# Setup fzf
# ---------
if [[ ! "$PATH" == */home/bob/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/bob/.fzf/bin"
fi

# Auto-completion
# ---------------
source "/home/bob/.fzf/shell/completion.zsh"

# Key bindings
# ------------
source "/home/bob/.fzf/shell/key-bindings.zsh"