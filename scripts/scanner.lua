--- Parses scan output and makes it available through the scanner object.
--
-- Author: Aleron

scanner = scanner or {}
scanner.config = {
  -- Controls whether articles ('a', 'an', 'the') are removed from the start of items.
  removeArticles = true
}
scanner.rooms = scanner.rooms or {}

local textNumbers = "(two|three|four|five|six|seven|eight|nine|ten|eleven|twelve)"

--- Enable the scanner.
function scanner:enable()
  enableTrigger("scanner")
end

--- Disable the scanner
function scanner:disable()
  disableTrigger("scanner")
end

--- Clear the list of mobs in all rooms
function scanner:clear()
  scanner.rooms = {}
end

--- Clear the list of mobs in a specific direction
function scanner:clearRoom(direction)
  scanner.rooms[direction] = {}
end

--- Returns the list of mobs in a given direction.
function scanner:getRoom(dir)
  if (dir == "n") then
    return scanner.rooms.north
  elseif (dir == "s") then
    return scanner.rooms.south
  elseif (dir == "e") then
    return scanner.rooms.east
  elseif (dir == "w") then
    return scanner.rooms.west
  elseif (dir == "u") then
    return scanner.rooms.up
  elseif (dir == "d") then
    return scanner.rooms.down
  else
    return scanner.rooms[dir]
  end
end

function scanner:getAllRooms()
  return scanner.rooms
end

-- Take a mob string with a word quantity, like "two rats", and translate it
-- into an array of strings:
-- { "rats", "rats" }
-- If the input string doesn't start with a number word, just return the string
local function flattenMultiple(input)
  local count, subject = string.match(input, "(%a+) (.+)")
  if (count) then
    count = numberStringToNumber(count)
    if (count) then
      local result = {}
      for i=1,count do table.insert(result, subject) end
      return result
    else
      return input
    end
  else
    return input
  end
end

-- Take a mob list from scan output and add the contents to the
-- scanner direction list that was specified. Remove indefinite articles
-- and interpret quantifiers.
--
-- Example input: "an aardvark, a bat, two dogs, three cats
-- Output:
--   { "aardvark", "bat", "dogs", "dogs", "cats", "cats", "cats" }
function scanner:addMobs(direction, mobs)
  if (not scanner.rooms[direction]) then
    scanner.rooms[direction] = {}
  end

  -- Split the mob string
  local rawItems = string.split(mobs, ", ")

  for i,val in ipairs(rawItems) do

    -- Remove articles.
    if (scanner.config.removeArticles) then
      val = string.gsub(val, "^a ", "", 1)
      val = string.gsub(val, "^an ", "", 1)
      val = string.gsub(val, "^the ", "", 1)
    end

    val = flattenMultiple(val)
    if (type(val) == "table") then
      for _,v in ipairs(val) do
        table.insert(scanner.rooms[direction], v)
      end
    else
      table.insert(scanner.rooms[direction], val)
    end
  end
end
