function print(content)
  if type(content) == "table" then
    game.print(serpent.line(content))
  else
    game.print(content)
  end
end

function count(list)
  local count = 0
  for _,__ in pairs(list) do
      count = count + 1
  end
  print(count)
end
