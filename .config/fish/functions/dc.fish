# Defined in /Users/miju/.config/fish/functions/d.fish @ line 2
function dc --wraps=docker-compose --wraps=docker --description 'alias dc=docker'
  docker-compose  $argv;
end
