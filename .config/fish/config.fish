# removing fish greeting
set fish_greeting
# Aliases

# LS
alias ls='eza -lah --classify --icons --group-directories-first' # pretty useful defulat command

#File operations
alias mv='mv -i' # confirms before doing
alias rm='rm -i' # comifrms before deleting
alias cp='cp -i' # confirms before copying

#Git
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'

#NixOS Specifc
alias ns='sudo nixos-rebuild switch --flake ~/nixos#nixos'

#Misc
alias s='sudo '
alias n='nvim '

# Auto-start Hyprland on tty1
if status is-login
    if test (tty) = /dev/tty1
        exec start-hyprland
    end
end


# Explicitly point Fish to your config file

# Initialize Starship
starship init fish | source



