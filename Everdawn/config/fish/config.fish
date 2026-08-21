set fish_cursor_insert line

if status is-interactive
    fastfetch

end

starship init fish | source
