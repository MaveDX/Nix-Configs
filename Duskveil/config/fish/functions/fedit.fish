function fedit --wraps='sudo nvim /etc/nixos/flake.nix' --description 'alias fedit=sudo nvim /etc/nixos/flake.nix'
    sudo nvim /etc/nixos/flake.nix $argv
end
