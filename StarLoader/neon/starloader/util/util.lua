slutil = { }


local function _toString(value, isKey, depth, maxDepth, style)
	if type(value) == "number" then return style[18] .. tostring(value)
	elseif type(value) == "string" then return isKey and (style[1] .. value .. style[2]) or (style[3] .. value .. style[4])
	elseif type(value) == "table" then
		if depth == maxDepth then return style[20] .. "table" end
		depth = depth + 1
		local isArray = true
		local i = 1
		for k, _ in pairs(value) do
			if i ~= k then
				isArray = false
				break
			else
				i = i + 1
			end
		end
		local bracketSpace = (style[16] == '') and style[12] or ''
		local separator =  style[13] .. ((style[16] == '') and (style[14] .. style[15]) or style[14])
		local out = (isArray and style[10] or style[8]) .. bracketSpace
		local comma = true
		for k, v in pairs(value) do
			if comma then comma = false
			else out = out .. separator end
			out = out .. style[16] .. style[17]:rep(depth)
			if not isArray then
				out = out .. _toString(k, true, depth, maxDepth, style) .. style[5] .. style[6] .. style[7]
			end
			out = out .. _toString(v, false, depth, maxDepth, style)
		end
		out = out .. style[16] .. bracketSpace .. style[17]:rep(depth-1) .. (isArray and style[11] or style[9])
		return out
	elseif type(value) == "boolean" then return style[19] .. (value and "true" or "false")
	elseif type(value) == "function" then return style[20] .. "function"
	elseif type(value) == "nil" then return style[20] .. "nil"
	elseif type(value) == "userdata" then return style[20] .. "userdata"
	elseif type(value) == "thread" then return style[20] .. "thread"
	else return style[20] .. "unknown" end
end

--style
--normal json
--min json
--pretty json
--normal lua
--min lua
--pretty lua
--experimental

function slutil.toString(value, maxDepth, style)
	if style == nil then style = "normal json" end
	if maxDepth == nil then maxDepth = 2 end

	if type(style) == "string" then
		style = style:lower()
		-- stringKeyPrefix stringKeySuffix stringValuePrefix stringValueSuffix equalsPrefix equals equalsPostfix mapOpens mapCloses arrOpens arrCloses tableInnerSpace separatorPrefix separator separatorSuffix newline tab numberPrefix boolPrefix otherTypePrefix globalPrefix
		if style == "json" or style == "normal json" then   style = 	{ '"', '"', '"', '"', ' ', ':', ' ', '{', '}', '[', ']', ' ', '', ',', ' ', '',   '',     '', '', '', '' }
		elseif style == "min json" then 					style = 	{ '"', '"', '"', '"', '' , ':', '' , '{', '}', '[', ']', '' , '', ',', '' , '',   '',     '', '', '', '' }
		elseif style == "pretty json" then 					style = 	{ '"', '"', '"', '"', ' ', ':', ' ', '{', '}', '[', ']', ' ', '', ',', ' ', '\n', '    ', '', '', '', '' }
		elseif style == "lua" or style == "normal lua" then style = 	{ '' , '' , '"', '"', ' ', '=', ' ', '{', '}', '{', '}', ' ', '', ',', ' ', '',   '',     '', '', '', '' }
		elseif style == "min lua" then 					    style =     { '' , '' , '"', '"', '' , '=', '' , '{', '}', '{', '}', '' , '', ',', '' , '',   '',     '', '', '', '' }
		elseif style == "pretty lua" then 					style = 	{ '' , '' , '"', '"', ' ', '=', ' ', '{', '}', '{', '}', ' ', '', ',', ' ', '\n', '    ', '', '', '', '' }
		elseif style == "experimental" then 				style = 	{ '^#9CDCFE;"', '"', '^#CE9175;"', '"', '', '^#D4D4D4;:', ' ', '^#FFD703;{', '^#FFD703;}', '^#179FFF;[', '^#179FFF;]', '', '', '^#D4D4D4;,', ' ', '\n', '    ', '^#B5CEA8;', '^#4887BB;', '^#F44747;', '^shadow;' }
		else error("Unknown style preset. Try these: json, lua", 2) end
	elseif type(style) ~= "table" or #style ~= 22 then 
		error('"style" argument is wrong', 2)
	end

	return style[21] .. _toString(value, false, 0, maxDepth, style)
end

--temp

function slutil.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[slutil.deepcopy(orig_key)] = slutil.deepcopy(orig_value)
        end
        setmetatable(copy, slutil.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
function slutil.HSVToRGB( hue, saturation, value )
	-- Returns the RGB equivalent of the given HSV-defined color
	-- (adapted from some code found around the web)

	-- If it's achromatic, just return the value
	if saturation == 0 then
		return {value, value, value}
	end;

	-- Get the hue sector
    local hue_ = math.fmod(hue, 360)
	local hue_sector = math.floor( hue_ / 60 );
	local hue_sector_offset = ( hue_ / 60 ) - hue_sector;

	local p = value * ( 1 - saturation );
	local q = value * ( 1 - saturation * hue_sector_offset );
	local t = value * ( 1 - saturation * ( 1 - hue_sector_offset ) );
	if hue_sector == 0 then
		return {value * 255, t * 255, p * 255}
	elseif hue_sector == 1 then
		return {q * 255, value * 255, p * 255}
	elseif hue_sector == 2 then
		return {p * 255, value * 255, t * 255}
	elseif hue_sector == 3 then
		return {p * 255, q * 255, value * 255}
	elseif hue_sector == 4 then
		return {t * 255, p * 255, value * 255}
	elseif hue_sector == 5 then
		return {value * 255, p * 255, q * 255}
	end;
end
local actions = { }
function slutil.action(action)
	table.insert(actions, action)
end
function slutil.actionText(text)
	slutil.action({
		action = "particle",
		specification = {
		  layer = "front",
		  text = text,
		  size = 0.4,
		  timeToLive = 0.01,
		  destructionAction = "fade",
		  destructionTime = 0.05,
		  type = "text",
		  fullbright = true
		}
	  })
end
function slutil.post(entityId)
	if entityId == nil then
		if entity then entityId = entity.id()
		elseif player then entityId = player.id() end
	end
	if #actions ~= 0 then
		world.spawnProjectile("marioball", world.entityPosition(entityId), entityId, {0, 0}, true, { movementSettings = { gravityEnabled = false, frictionEnabled = false, collisionEnabled = false }, processing = "?scalenearest=0", timeToLive = 0, power = 0, damageType = "NoDamage", speed = 0, actionOnReap = actions })
		actions = { }
	end
end