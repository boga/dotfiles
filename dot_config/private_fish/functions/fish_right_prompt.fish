function fish_right_prompt
    set -g __fish_git_prompt_showdirtystate 1

    set -l git_prompt (fish_git_prompt)
    if test "$git_prompt" != ""
        set git_prompt "$git_prompt "
    end

    echo -n -s $git_prompt (prompt_pwd)
end
