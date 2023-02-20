local screen_size_x = math.ceil(1730)--1680 / 2)--1730
local screen_size_y = math.ceil(685)--987 / 2)--685
local screen_size_max = {9600,4320}--root.imageSize(config.getParameter("gui.background.fileBody"))
local min_valid_resolution = {100,100}

local sidebar_width
local label_height
local label_content_height
local sidebar_content_width

local firstupdate = true

local check_interval = 0.1 -- check every 5 seconds
local timer = 0

local starhubstaticloaded = false

local slMainConf
local slModuleConf

local sidebarobjects = {}
local parentName = ""
local authors = {}

local function populate()
  sidebar_width = math.min(350, screen_size_x / 3)
  label_height = math.min(100, screen_size_y / 6)
  label_content_height = label_height - 20
  sidebar_content_width = sidebar_width - 20

  scrollableSideBarTop = screen_size_y - label_height


  if not starhubstaticloaded then
    widget.setImage("back", "/neon/starloader/core/starhub/gui/pixel.png?multiply=000000BB?scalenearest=" .. 9600 .. ";" .. 4320)

    widget.setImage("sidebar", "/neon/starloader/core/starhub/gui/pixel.png?multiply=000000BB?scalenearest=" .. sidebar_width .. ";" .. screen_size_y)
    
    widget.setImage("sidebar_header", "/neon/starloader/core/starhub/gui/pixel.png?multiply=000000FF?scalenearest=" .. sidebar_width .. ";" .. label_height)
    widget.setPosition("sidebar_header", {0,(screen_size_y - label_height)})

    widget.setSize("sidebarscrollarea", {sidebar_width, screen_size_y - 2 * label_height})
    widget.setPosition("sidebarscrollarea", {0, label_height})

    widget.setSize("contentscrollarea", {screen_size_x - sidebar_width, screen_size_y})
    widget.setPosition("contentscrollarea", {sidebar_width, 0})

    local size = root.imageSize("/neon/starloader/core/starhub/gui/starhub.png")
    size[1] = size[1] / 2
    size[2] = size[2] / 2

    widget.setImage("sidebar_logo", "/neon/starloader/core/starhub/gui/starhub.png?scale=" .. math.min(sidebar_content_width / size[1], label_content_height / size[2]))
  
    local adjustedsize = size[1] * math.min(sidebar_content_width / size[1], label_content_height / size[2])

    widget.setPosition("sidebar_logo", {((sidebar_width - adjustedsize) / 2),(screen_size_y - label_height + 10)})

    widget.setImage("sidebar_footer", "/neon/starloader/core/starhub/gui/pixel.png?multiply=000000FF?scalenearest=" .. sidebar_width .. ";" .. label_height)

    widget.setPosition("sidebar_disclaimer", {0,0})


    --"This is an\nEXPERIMENTAL\nversion.\nNot finished!\nStuff WILL change."
    --sidebar_disclaimer

    --widget.setImage("separator", "/neon/starloader/core/starhub/gui/line.png?multiply=00000000?scale=" .. 1 .. ";" .. screen_size_y / 2) --?multiply=00000000
    --widget.setPosition("separator", {sidebar_width, 0})

    -- Clear all widgets from the container and make new ones
    widget.removeAllChildren("sidebarscrollarea")

    -- Check if StarLoader has given its Modules to StarHub
    if slModuleConf then
      sidebarobjects = {}
      --sb.logInfo("test")
      moduleindex = 0
      for modulename, moduleparams in next, slModuleConf.modules do
        local author = moduleparams["author"] or "unknown"
        sidebarobjects[author] = sidebarobjects[author] or {}
        table.insert(sidebarobjects[author], {modulename, moduleparams})

        moduleindex = moduleindex + 1
      end

      authors = {}
      for k in next, sidebarobjects do
        table.insert(authors, k)
      end
      table.sort(authors)

      local sidebarobjectsindex = 1
      parentName = "sidebarscrollarea"

      local placeholderName = parentName .. ".placeholder"
      widget.addChild(parentName, {
        type = "image",
        file = "",
        zlevel = 5,
        maxSize	= {0, 0},
        position = {0, 0}
      }, placeholderName)

      for i = 1, #authors do
        local author = authors[i]
        local modules = sidebarobjects[author]
        local size = root.imageSize("/neon/starloader/core/starhub/gui/arrow-down.png")
          size[1] = size[1] / 2
          size[2] = size[2] / 2

          local backButtonName = parentName .. ".author." .. author
          widget.addChild(parentName, {
            type = "button",
            base = "/neon/starloader/core/starhub/gui/pixel.png?multiply=00000000?scalenearest=" .. sidebar_width .. ";40",
            hover = "/neon/starloader/core/starhub/gui/pixel.png?multiply=222222BB?scalenearest=" .. sidebar_width .. ";40",
            pressed = "/neon/starloader/core/starhub/gui/pixel.png?multiply=333333BB?scalenearest=" .. sidebar_width .. ";40",
            disabledImage = "/neon/starloader/core/starhub/gui/pixel.png?multiply=00000000?scalenearest=" .. sidebar_width .. ";40",
            pressedOffset = {0, 0},
            callback = "sidebarPress",
            zlevel = 3,
            maxSize	= {40, sidebar_width},
            position = {0, 40 * -sidebarobjectsindex - 2}
          }, backButtonName)

          local arrowName = parentName .. ".arrow" .. sidebarobjectsindex
          widget.addChild(parentName, {
            type = "image",
            file = "/neon/starloader/core/starhub/gui/arrow-down.png?scalenearest=" .. math.min(20 / size[1], 20 / size[2]),
            zlevel = 5,
            maxSize	= {20, 20},
            position = {20, 10 + 40 * -sidebarobjectsindex - 2},
            mouseTransparent = true
          }, arrowName)
        
          local authorName = parentName .. ".authorname" .. sidebarobjectsindex
          widget.addChild(parentName, {
              type = "label",
              value = author,
              zlevel = 5,
              fontSize = 15,
              position = {60, 10 + 40 * -sidebarobjectsindex},
              mouseTransparent = true
          }, authorName)
          sidebarobjectsindex = sidebarobjectsindex + 1

        for j = 1, #modules do
          local module = modules[j]
          local modulename, moduleparams = module[1], module[2]
          local size = root.imageSize("/neon/starloader/core/starhub/gui/slider-on.png")
        size[1] = size[1] / 2
        size[2] = size[2] / 2

        local backButtonName = parentName .. ".module." .. modulename
        widget.addChild(parentName, {
          type = "button",
          base = "/neon/starloader/core/starhub/gui/pixel.png?multiply=00000000?scalenearest=" .. sidebar_width .. ";40",
          hover = "/neon/starloader/core/starhub/gui/pixel.png?multiply=222222BB?scalenearest=" .. sidebar_width .. ";40",
          pressed = "/neon/starloader/core/starhub/gui/pixel.png?multiply=333333BB?scalenearest=" .. sidebar_width .. ";40",
          disabledImage = "/neon/starloader/core/starhub/gui/pixel.png?multiply=00000000?scalenearest=" .. sidebar_width .. ";40",
          pressedOffset = {0, 0},
          callback = "sidebarPress",
          zlevel = 3,
          maxSize	= {40, sidebar_width},
          position = {0, 40 * -sidebarobjectsindex - 2}
        }, backButtonName)

        local backButtonName = parentName .. ".moduleslider." .. modulename
        widget.addChild(parentName, {
          type = "button",
          base = "/neon/starloader/core/starhub/gui/slider-on.png?scalenearest=" .. math.min(10 / size[1], 10 / size[2]),
          hover = "/neon/starloader/core/starhub/gui/slider-on.png?scalenearest=" .. math.min(10 / size[1], 10 / size[2]),
          pressed = "/neon/starloader/core/starhub/gui/slider-on.png?scalenearest=" .. math.min(10 / size[1], 10 / size[2]),
          disabledImage = "/neon/starloader/core/starhub/gui/slider-off.png?scalenearest=" .. math.min(10 / size[1], 10 / size[2]),
          pressedOffset = {0, 0},
          callback = "sliderPress",
          zlevel = 5,
          maxSize	= {20, 20},
          position = {20, 10 + 40 * -sidebarobjectsindex - 2}
        }, backButtonName)

        -- local sliderName = parentName .. ".slider." .. modulename
        -- widget.addChild(parentName, {
        --   type = "image",
        --   file = "/neon/starloader/core/starhub/gui/slider-on.png?scalenearest=" .. math.min(20 / size[1], 20 / size[2]),
        --   zlevel = 5,
        --   maxSize	= {20, 20},
        --   position = {20, 10 + 40 * -sidebarobjectsindex - 2},
        --   mouseTransparent = true
        -- }, sliderName)
      
        local moduleName = parentName .. ".modulename" .. sidebarobjectsindex
        widget.addChild(parentName, {
            type = "label",
            value = modulename,
            zlevel = 5,
            fontSize = 15,
            position = {60, 10 + 40 * -sidebarobjectsindex},
            mouseTransparent = true
        }, moduleName)
        sidebarobjectsindex = sidebarobjectsindex + 1
        end
      end
    end
    --createWidgets("sidebarscrollarea", 40)

    starhubstaticloaded = true
  end
end
function sliderPress(widgetname, widgetdata)
  sb.logInfo("%s, %s", widgetname, widgetdata)
  if string.find(widgetname,"sidebarscrollarea.moduleslider.") then
    calledButtonName = string.gsub(widgetname, "sidebarscrollarea.moduleslider.", "")
    size = root.imageSize("/neon/starloader/core/starhub/gui/slider-on.png")
    size[1] = size[1] / 2
    size[2] = size[2] / 2
    return
  end
end

function sidebarPress(widgetname, widgetdata)
  sb.logInfo("%s, %s", widgetname, widgetdata)
  local calledButtonName = ""
  local calledButtonDescription = ""
  local size
  local logo
  if string.find(widgetname,"sidebarscrollarea.module.") then
    calledButtonName = string.gsub(widgetname, "sidebarscrollarea.module.", "")
    for i = 1, #authors do
      local author = authors[i]
      local modules = sidebarobjects[author]
      for j = 1, #modules do
        local module = modules[j]
        local modulename, moduleparams = module[1], module[2]
        if modulename == calledButtonName then
          calledButtonDescription = "This is an Module.\n" .. moduleparams["description"] or "This is an Module.\nNo Description."
          logo = moduleparams["logo"]
          size = root.imageSize(logo)
          size[1] = size[1] / 2
          size[2] = size[2] / 2
          break
        end
      end
    end
  else
    calledButtonName = string.gsub(widgetname, "sidebarscrollarea.author.", "")
    calledButtonDescription = "This is an Author.\nAuthor Modules: "
    for i = 1, #authors do
      local author = authors[i]
      if author == calledButtonName then
        logo = "/neon/starloader/core/starhub/gui/logo-smol.png"
        size = root.imageSize(logo)
        size[1] = size[1] / 2
        size[2] = size[2] / 2
        local modules = sidebarobjects[author]
        for j = 1, #modules do
          local module = modules[j]
          local modulename, moduleparams = module[1], module[2]
          calledButtonDescription = calledButtonDescription .. modulename .. " "
        end
        break
      end
    end
  end


  parentName = "contentscrollarea"
  widget.removeAllChildren("contentscrollarea")
  local placeholderName = parentName .. ".placeholder"
  widget.addChild(parentName, {
    type = "image",
    file = "",
    zlevel = 5,
    maxSize	= {0, 0},
    position = {0, 0}
  }, placeholderName)

  local moduleLogo = parentName .. ".logo"
  widget.addChild(parentName, {
    type = "image",
    file = logo .. "?scalenearest=" .. math.min(60 / size[1], 60 / size[2]),
    zlevel = 5,
    maxSize	= {60, 60},
    position = {20, -80},
    mouseTransparent = true
  }, moduleLogo)
  local moduleName = parentName .. ".name"
  widget.addChild(parentName, {
    type = "label",
    value = calledButtonName,
    zlevel = 5,
    fontSize = 20,
    position = {100, -48},
    mouseTransparent = true
  }, moduleName)
  local moduleDescription = parentName .. ".description"
  widget.addChild(parentName, {
    type = "label",
    value = calledButtonDescription,
    zlevel = 5,
    fontSize = 10,
    position = {100, -73},
    mouseTransparent = true
  }, moduleDescription)
  
end

function init()
  firstupdate = true
end


function displayed()
  firstupdate = false
end


function createTooltip(screenPosition)
end


local function scan_x(x, i, step)
  if i < 1 then
    if widget.getChildAt({x, 0}) then
      return x
    end
    return x - step
  end
  local child = widget.getChildAt({x, 0})
  if child then
    return scan_x(x + i, i / 2, step)
  end
  return scan_x(x - i, i / 2, -step)
end

local function scan_y(y, i, step)
  if i < 1 then
    if widget.getChildAt({0, y}) then
      return y
    end
    return y - step
  end
  local child = widget.getChildAt({0, y})
  if child then
    return scan_y(y + i, i / 2, step)
  end
  return scan_y(y - i, i / 2, -step)
end

function update(dt)
  if not slMainConf then
    slMainConf = os.__slmainconf
  end
  if not slModuleConf then
    slModuleConf = os.__slmoduleconf
  end
  if firstupdate then
    local scx = scan_x(screen_size_max[1], screen_size_max[1] / 2, -1)
    local scy = scan_y(screen_size_max[2], screen_size_max[2] / 2, -1)
    if scx < min_valid_resolution[1] then scx = min_valid_resolution[1] end
    if scy < min_valid_resolution[2] then scy = min_valid_resolution[2] end
    if screen_size_x == scx and screen_size_y == scy then
      firstupdate = false
    end
    if scx > screen_size_max[1] then scx = screen_size_max[1] end
    if scy > screen_size_max[2] then scy = screen_size_max[2] end
    screen_size_x = scx
    screen_size_y = scy
  end
  timer = timer + dt
  if timer >= check_interval then
    timer = 0
    local ToSmall = widget.getChildAt({screen_size_x-2, screen_size_y-2})
    local ToBig = widget.getChildAt({screen_size_x+2, screen_size_y+2})
    if ToSmall and not ToBig then
    else
      firstupdate = true
      starhubstaticloaded = false
    end
  end


  if screen_size_x > 0 and screen_size_y > 0 and firstupdate == false then
    populate()
  end
end


function cursorOverride(screenPosition)
  return "/neon/starloader/core/starhub/gui/cursor/neon.cursor"
end


function dismissed()
end


function uninit()
end


function compare(a,b)
  return a < b
end


-- Function to create widgets
function createWidgets(parentName, numWidgets)
  -- Loop to create the specified number of widgets
  local placeholderName = parentName .. ".placeholder"
  widget.addChild(parentName, {
    type = "image",
    file = "",
    zlevel = 5,
    maxSize	= {0,0},
    position = {0, 0}
  }, placeholderName)

  for i = 1, numWidgets do

    local size = root.imageSize("/neon/starloader/core/starhub/gui/slider-on.png")
    size[1] = size[1] / 2
    size[2] = size[2] / 2
    local sliderName = parentName .. ".slider" .. i
    widget.addChild(parentName, {
      type = "image",
      file = "/neon/starloader/core/starhub/gui/slider-on.png?scalenearest=" .. math.min(20 / size[1], 20 / size[2]),
      zlevel = 5,
      maxSize	= {20,20},
      position = {20, 10 + 40*-i - 2}
    }, sliderName)

    local labelName = parentName .. ".label" .. i
    widget.addChild(parentName, {
        type = "label",
        value = "TestModule " .. i,
        zlevel = 5,
        fontSize = 15,
        position = {60, 10 + 40*-i}
    }, labelName)
  end
end