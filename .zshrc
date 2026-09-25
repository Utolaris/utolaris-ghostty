#!/bin/zsh
# ─── terminal-setup: Zsh config ─────────────────────────────────────
# Starship + zsh-autosuggestions + zsh-syntax-highlighting 

# ─── Homebrew ────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# ─── FFmpeg (Homebrew ffmpeg-full, keg-only) ────────────────────────
export PATH="/opt/homebrew/opt/ffmpeg-full/bin:$PATH"

# ─── Starship prompt ────────────────────────────────────────────────
# Enabling Starship in Ghostty, specially.
if [[ "${TERM_PROGRAM:l}" == "ghostty" ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship.toml"
    eval "$(starship init zsh)"
fi

# ─── Zsh plugins (via Homebrew) ──────────────────────────────────────
# Syntax highlighting (must be before autosuggestions for best results)
if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions (fish-like suggestions)
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

# Completions
if [[ -d /opt/homebrew/share/zsh-completions ]]; then
    fpath=(/opt/homebrew/share/zsh-completions $fpath)
fi
autoload -Uz compinit
# Prefer the cached completion dump for faster shell startup.
if [[ -f ~/.zcompdump ]]; then
    compinit -C
else
    compinit
fi

# ─── History ─────────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# ─── Zoxide (smart cd) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"


# ─── Aliases ─────────────────────────────────────────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias top='btop'


# ─── User environment ───────────────────────────────────────────────
# Added by Antigravity
export PATH="/Users/utolaris/.antigravity/antigravity/bin:$PATH"

# uv
eval "$(uv generate-shell-completion zsh)"

# Bash `mapfile`/`readarray` compatibility for zsh.
if ! whence -w mapfile >/dev/null 2>&1; then
    mapfile() {
        emulate -L zsh
        setopt localoptions noshwordsplit

        local trim_newlines=0 opt
        while getopts ":t" opt; do
            case "$opt" in
                t) trim_newlines=1 ;;
                \?)
                    print -u2 "mapfile: unsupported option -- $OPTARG"
                    return 2
                    ;;
            esac
        done
        shift $((OPTIND - 1))

        local array_name="${1:-MAPFILE}"
        local -a lines=()
        local line

        while IFS= read -r line || [[ -n "$line" ]]; do
            if (( trim_newlines )); then
                lines+=("$line")
            else
                lines+=("$line"$'\n')
            fi
        done

        typeset -g -a "$array_name"
        eval "$array_name=(${(j: :)${(q)lines[@]}})"
    }

    alias readarray='mapfile'
fi

export PATH="/Users/utolaris/Documents/ai/stata-cli/skill/stata-cli/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"


# Added by Antigravity CLI installer
export PATH="/Users/utolaris/.local/bin:$PATH"

# mimocode
export PATH=/Users/utolaris/.bun/bin:/Users/utolaris/.mimocode/bin:$PATH

# Tushare API token from macOS Keychain (service: tushare-token)
# Store once: security add-generic-password -U -a "$USER" -s tushare-token -w 'YOUR_TOKEN'
export TUSHARE_TOKEN="$(security find-generic-password -a "$USER" -s tushare-token -w 2>/dev/null)"


# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<

# PyGhidra
export GHIDRA_INSTALL_DIR="/opt/homebrew/opt/ghidra/libexec"

# ─── Quick text transfer ────────────────────────────────────────────
# Set TEXT_SYNC_HOST to override the default SSH host: export TEXT_SYNC_HOST=kali
sendtext() {
    pbpaste | ssh "${TEXT_SYNC_HOST:-kali}" '~/.local/bin/kclip'
}

gettext() {
    ssh "${TEXT_SYNC_HOST:-kali}" '~/.local/bin/kclip get' | pbcopy
}
