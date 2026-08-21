function rehome --wraps='home-manager switch -b backup' --description 'alias rehome=home-manager switch -b backup'
    home-manager switch -b backup $argv
end
