function hedit --wraps='sudo nvim /etc/nixos/home.nix' --description 'alias hedit=sudo nvim /etc/nixos/home.nix'
    sudo nvim /etc/nixos/home.nix $argv
end
