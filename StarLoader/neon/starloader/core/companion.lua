local _init = init or function() end
local _update = update or function() end
local _uninit = uninit or function() end

function init(...)
    return _init(...)
end

function update(...)
    return _update(...)
end

function uninit(...)
    return _uninit(...)
end