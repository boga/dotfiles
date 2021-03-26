# Defined in - @ line 1
function T --wraps='tmux' --description 'alias T=tmux attach || tmux new'
  tmux attach || tmux new $argv;
end
