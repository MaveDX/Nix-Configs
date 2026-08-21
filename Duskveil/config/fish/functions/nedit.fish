function nedit --wraps='sudo nvim /etc/nixos/configuration.nix' --description 'alias nedit=sudo nvim /etc/nixos/configuration.nix'
    sudo nvim /etc/nixos/configuration.nix $argv
end
