function update --wraps='nh os switch --update' --description 'alias update=nh os switch --update'
    nh os switch --update $argv
end
