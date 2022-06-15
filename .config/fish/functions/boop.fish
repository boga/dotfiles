function boop
  set --local last "$status"
  set --local sound "$HOME/Documents/Sounds/pr.wav"

  if test -z $last
    return 0
  end

  if test 0 -ne $last
    set sound "$HOME/Documents/Sounds/Zvuki_2/Vistrel.mp3"
  end

  set sound $(realpath $sound)

  afplay $sound

  return "$last"
end
