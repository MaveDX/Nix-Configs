function rebuild --wraps='nh os switch /home/ozgur/.config/nixos/flake.nix' --wraps='nh os switch /home/ozgur/.config/nixos' --description 'alias rebuild=nh os switch /home/ozgur/.config/nixos'
    nh os switch /home/ozgur/.config/nixos $argv
end
