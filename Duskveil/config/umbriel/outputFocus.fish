#!/run/current-system/sw/bin/fish

function focus-output
    set -l dir $argv[1]
    set -l opposite

    switch $dir
        case right; set opposite left
        case left;  set opposite right
        case up;    set opposite down
        case down;  set opposite up
        case '*'
            echo "Usage: output-focus <left|right|up|down>"
            exit 1
    end

    set -l result (umbriel msg output-focus-$dir 2>&1)

    if string match -qi "*no output to the $dir*" -- $result
        umbriel msg output-focus-$opposite
    else if test -n "$result"
        echo $result
    end
end

focus-output $argv[1]
