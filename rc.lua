
--[[
                                       
     Awesome WM configuration template 
     github.com/copycat-killer         
                                       
--]]

-- {{{ Required libraries
local awesome, client, screen, tag = awesome, client, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type
local mouse = mouse

local_config = require("local")
util = require("util")

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- }}}
--
local revelation=require("revelation")

local function restart()
    if local_config.restart then
        local_config.restart()
    else
        awesome.restart()
    end
end


local cyclefocus = require('cyclefocus')
cyclefocus.show_clients = true
cyclefocus.raise_client = true
cyclefocus.focus_clients = true

-- {{{ Error handling
--if awesome.startup_errors then
    --naughty.notify({ preset = naughty.config.presets.critical,
                     --title = "Oops, there were errors during startup!",
                     --text = awesome.startup_errors })
--end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        findme = cmd
        firstspace = cmd:find(" ")
        if firstspace then
            findme = cmd:sub(0, firstspace-1)
        end
        awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
    end
end

local function debug(str)
  naughty.notify({text = tostring(str)})
end

run_once({ "urxvtd", "unclutter -root" })
-- }}}

-- {Ma{{ Variable definitions
local chosen_theme = "holo"
local modkey       = util.modkey
local altkey       = util.altkey
local terminal     = "urxvtc" or "xterm"
local editor       = os.getenv("EDITOR") or "nano" or "vi"
local gui_editor   = "gvim"
local browser      = "firefox"

awful.util.terminal = terminal
awful.util.tagnames = { "1", "2" }
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
    --lain.layout.cascade,
    --lain.layout.cascade.tile,
    --lain.layout.centerwork,
    --lain.layout.centerwork.horizontal,
    --lain.layout.termfair,
    --lain.layout.termfair.center,
}
awful.util.taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )
awful.util.tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function()
                         local instance = nil

                         return function ()
                             if instance and instance.wibox.visible then
                                 instance:hide()
                                 instance = nil
                             else
                                 instance = awful.menu.clients({ theme = { width = 250 } })
                             end
                        end
                     end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

lain.layout.termfair.nmaster           = 3
lain.layout.termfair.ncol              = 1
lain.layout.termfair.center.nmaster    = 3
lain.layout.termfair.center.ncol       = 1
lain.layout.cascade.tile.offset_x      = 2
lain.layout.cascade.tile.offset_y      = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster       = 5
lain.layout.cascade.tile.ncol          = 2

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)
revelation.init()
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", restart },
    { "quit", function() awesome.quit() end }
}
awful.util.mymainmenu = freedesktop.menu.build({
    icon_size = beautiful.menu_height or 16,
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Screen
-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end)
-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s) beautiful.at_screen_connect(s) end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () awful.util.mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    awful.key({ modkey,           }, "a",      revelation),

    -- Volume control
    awful.key({ }, "XF86AudioRaiseVolume", function ()
      awful.util.spawn("amixer set Master 2%+")
    end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
      awful.util.spawn("amixer set Master 2%-")
    end),
    awful.key({ }, "XF86AudioMute", function ()
      awful.util.spawn("amixer set Master toggle")
    end),
    awful.key({ }, "XF86AudioMicMute", function ()
      awful.util.spawn("amixer set Capture toggle")
    end),
    awful.key({ }, 'Pause', function ()
      --awful.util.spawn("amixer set Capture off")
      awful.util.spawn("/home/chris/bin/toggle-mic.sh")
    end),


    -- Lock screen
		awful.key({ modkey, }, 'l', function ()
      os.execute('xscreensaver-command -lock')
		end),

    -- Goland
		awful.key({ altkey, }, 'g', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'jetbrains-goland'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('pycharm', matcher)
                end
		end),

    -- Pycharm
		awful.key({ altkey, }, 'p', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'jetbrains-pycharm-ce'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('pycharm', matcher)
                end
		end),

    -- Intellij Idea
		awful.key({ altkey, }, 'j', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'jetbrains-idea-ce'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('intellij-idea', matcher)
                end
		end),

    -- Slack
		awful.key({ altkey, }, 's', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'Slack'})
				end

                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('slack', matcher)
                end
		end),

    -- Firefox
		awful.key({ altkey, }, 'f', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'Firefox'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('firefox', matcher)
                end
		end),

    -- Postman
		awful.key({ altkey, }, 'p', function ()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'Postman'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('postman', matcher)
                end
		end),


    -- Arduino
       awful.key({ altkey, }, 'a', function()
				local matcher = function (c)
						return awful.rules.match(c, {class = 'processing-app-Base'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('arduino', matcher)
                end
		end),

    -- Vim Anywhere
		awful.key({ altkey, }, 'v', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'vim-anywhere'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('vim-anywhere vim urxvt -title terminal-anywhere ', matcher)
                end
		end),


    -- Chrome
		awful.key({ altkey, }, 'c', function ()
                local matcher = function (c)
                        return awful.rules.match(c, {class = 'Google-chrome'})
                end

                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('google-chrome-stable', matcher)
                end
		end),

    -- Notes
		awful.key({ altkey, }, 'n', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'terminal-notes'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('terminal-notes', matcher)
                end
		end),

    -- Logs
		awful.key({ altkey, }, 'l', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'terminal-logs'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('terminal-logs', matcher)
                end
		end),

    -- Conky
		awful.key({ altkey, "Shift" }, 'b', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'conky'})
				end
				awful.client.run_or_raise('conky', matcher)
    end),

    -- Dropdown terminal
		awful.key({ altkey, }, 'x', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'terminal-dropdown'})
				end
                if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
                    awful.client.run_or_raise('terminal-dropdown', matcher)
                end
		end),

    -- Print screen
    awful.key({ }, "Print", function () awful.util.spawn(os.getenv("HOME") .. "/bin/screenshot.sh") end),
		awful.key({ altkey, }, 'd', function ()
				local matcher = function (c)
						return awful.rules.match(c, {name = 'terminal-devel'})
				end
				awful.client.run_or_raise('terminal-devel', matcher)
		end),

    -- Alt tab
		--awful.key({ "Mod1",           }, "Tab",
			 --function ()
					 --switcher.switch( 1, "Alt_L", "Tab", "ISO_Left_Tab")
			 --end),

		--awful.key({ "Mod1", "Shift"   }, "Tab",
			 --function ()
					 --switcher.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
			 --end),

    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
              {description = "view  previous nonempty", group = "tag"}),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
              {description = "view  previous nonempty", group = "tag"}),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () awful.util.mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    --awful.key({ modkey,           }, "Tab",
        --function ()
            --awful.client.focus.history.previous()
            --if client.focus then
                --client.focus:raise()
            --end
        --end,
        --{description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
            if s.mybottomwibox then
                s.mybottomwibox.visible = not s.mybottomwibox.visible
            end
        end
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(-1) end),  -- move to previous tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(1) end),  -- move to next tag
    awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Copy primary to clipboard (terminals to gtk)
    awful.key({ modkey }, "c", function () awful.spawn("xsel | xsel -i -b") end),
    -- Copy clipboard to primary (gtk to terminals)
    awful.key({ modkey }, "v", function () awful.spawn("xsel -b | xsel") end),

    -- Prompt
    awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
    --]]
)

if local_config.globalkeys then
    globalkeys = awful.util.table.join(globalkeys, local_config.globalkeys)
end

clientkeys = awful.util.table.join(
    awful.key({ "Mod1" }, "Tab", function(c)
        cyclefocus.cycle({modifier="Alt_L"})
    end),
    awful.key({ "Mod1", "Shift" }, "Tab", function(c)
        cyclefocus.cycle({modifier="Alt_L"})
    end),
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ altkey }, "q", function (c) 
        if client == nil or client.focus == nil or client.focus.name ~= 'World of Warcraft [Streaming]' then
            c:kill()
        end
    end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- Mouse
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, function (c) 
      if c.maximized then
        c.maximized = false
      end
      awful.mouse.client.move()
    end),
    awful.button({ modkey }, 3, function (c)
      if c.maximized then
        c.maximized = false
      end
      awful.mouse.client.resize()
    end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
    awful.rules.rules = {
        { rule = { },
          properties = { border_width = beautiful.border_width,
                         border_color = beautiful.border_normal,
                         focus = awful.client.focus.filter,
                         raise = true,
                         keys = clientkeys,
                         buttons = clientbuttons,
                         screen = awful.screen.preferred,
                         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                         size_hints_honor = false
         }
        },
        -- Titlebars
        { rule_any = { type = { "dialog", "normal" } },
          properties = { titlebars_enabled = true } },

        { rule = { class = "Gimp", role = "gimp-image-window" },
              properties = { maximized = true } },

        -- my rules
        { rule = { class = "Steam" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },

        --{ rule = { class = "jetbrains-idea-ce" },
          --properties = { border_width = 0,
                         --titlebars_enabled = false,
                         --placement = awful.placement.maximize} },

        --{ rule = { class = "jetbrains-pycharm-ce" },
          --properties = { border_width = 0,
                         --titlebars_enabled = false,
                         --placement = awful.placement.maximize} },

        --{ rule = { class = "jetbrains-goland" },
          --properties = { border_width = 0,
                         --titlebars_enabled = false,
                         --placement = awful.placement.maximize} },

        { rule = { class = "conky" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         x = 1920,
                         y = 0,
                         width = 450,
                         height = 1200 }},

        { rule = { name = "Ulauncher" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },


        { rule = { name = "terminal-notes" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-logs" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-devel" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         floating = true,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-weechat" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { class = "Slack" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { class = "Google-chrome" },
          properties = { border_width = 2,
                         border_color = "#3465A4",
                         titlebars_enabled = false,
                         placement = awful.placement.centered} },

        { rule = { name = "terminal-dropdown" },
          properties = { border_width = 5,
                         titlebars_enabled = false,
                         placement = awful.placement.horizontally} },

        { rule = { name = "terminal-logs" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-devel" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         floating = true,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-weechat" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { name = "urxvt" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },
    }

if screen.count() == 3 then
    awful.rules.rules = {
        -- All clients will match this rule.
        { rule = { },
          properties = { border_width = beautiful.border_width,
                         border_color = beautiful.border_normal,
                         focus = awful.client.focus.filter,
                         raise = true,
                         keys = clientkeys,
                         buttons = clientbuttons,
                         screen = awful.screen.preferred,
                         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                         size_hints_honor = false
         }
        },

        -- Titlebars
        { rule_any = { type = { "dialog", "normal" } },
          properties = { titlebars_enabled = true } },

        { rule = { class = "Gimp", role = "gimp-image-window" },
              properties = { maximized = true } },

        -- my rules
        { rule = { class = "Steam" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },

        { rule = { class = "jetbrains-idea-ce" },
          properties = { border_width = 0,
                         x = 1920 + 320,
                         y = 1080 + 120,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { class = "jetbrains-pycharm-ce" },
          properties = { border_width = 0,
                         x = 1920 + 320,
                         y = 1080 + 120,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { class = "jetbrains-goland" },
          properties = { border_width = 0,
                         x = 1920,
                         y = 1080,
                         titlebars_enabled = false,
                         placement = awful.placement.maximize} },

        { rule = { class = "conky" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         x = 1920,
                         y = 0,
                         width = 450,
                         height = 1200 }},

        { rule = { name = "Ulauncher" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },


        { rule = { name = "terminal-notes" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         floating = true,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-logs" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         floating = true,
                         placement = awful.placement.maximize} },

        { rule = { name = "terminal-devel" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         floating = true,
                         placement = awful.placement.maximize} },

        { rule = { class = "Slack" },
          properties = { border_width = 0,
                         titlebars_enabled = false,
                         x = 0,
                         y = 1080,
                         width = 1920 - 500,
                         height = 1200} },

        { rule = { class = "Google-chrome" },
          properties = { border_width = 3,
                         border_color = "#3465A4",
                         titlebars_enabled = false,
                         x = 1920 + 320,
                         y = 1080 + 120,
                         width = 1920,
                         height = 1200} },

        { rule = { name = "terminal-dropdown" },
          properties = { border_width = 5,
                         titlebars_enabled = false,
                         placement = awful.placement.horizontally} },

        { rule = { name = "urxvt" },
          properties = { border_width = 0,
                         titlebars_enabled = false} },
    }
end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end

    -- work window layout --
    --if c.name and screen.count() == 3 then
      --if c.name == "terminal-dropdown" then
        --c.maximized_horizontal = false
        --c:geometry( { x = 1920, y = 0, height = 960, width = 100 } )
        --c.maximized_horizontal = true
      --end

      --if c.name == "terminal-notes" then
        --c.maximized_horizontal = false
        --c:geometry( { x = 1920, y = 0, height = 960, width = 100 } )
        --c.maximized_horizontal = true
      --end

      --if c.name == "terminal-devel" then
        --c.maximized = false 
        --c:geometry( { x = 1920, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "PyCharm") then
        --c.maximized = false 
        --c:geometry( { x = 4000, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "IntelliJ IDEA") then
        --c.maximized = false 
        --c:geometry( { x = 4000, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "Google Chrome") then
        --c.maximized = false 
        --c:geometry( { x = 4000, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "SpiderOak") then
        --c:geometry( { x = 0, y = 0 } )
        --c:lower()
      --end 

      --if string.find(c.name, "Slack") then
        --c.maximized = false 
        --c:geometry( { x = 0, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if c.name == "terminal-logs" then
        --c.maximized = false
        --c:geometry( { x = 1920, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "Postman") then
        --c.maximized = false 
        --c:geometry( { x = 4000, y = 0, width = 100, height = 100 } )
        --c.maximized = true
      --end

      --if string.find(c.name, "KeePass") then
         --c:geometry( { x = 2025, y = 500, height = 1000, width = 1000 } )
      --end
    --end

    -- laptop only window layout --
    if c.name and screen.count() == 1 then
      if c.name == "terminal-dropdown" then
        c:geometry( { x = 0, y = 0, height = 540 } )
        c.maximized_horizontal = true
      end

      if c.name == "terminal-notes" then
        --c:geometry( { x = 0, y = 0, height = 540 } )
        --c.maximized_horizontal = true
      end

      if c.name == "terminal-devel" then
        c:geometry( { x = 0, y = 0 } )
        c.maximized = true
      end

      if string.find(c.name, "PyCharm") then
        c:geometry( { x = 0, y = 0 } )
        c.maximized = true
      end

      if string.find(c.name, "IntelliJ IDEA") then
        c:geometry( { x = 0, y = 0 } )
        c.maximized = true
      end

      if string.find(c.name, "Google Chrome") then
        c:geometry( { x = 0, y = 0 } )
        c.maximized = true
      end

      if string.find(c.name, "SpiderOak") then
        c:geometry( { x = 0, y = 0 } )
        c:lower()
      end 

      if string.find(c.name, "Slack") then
         --c:geometry( { x = 0, y = 0} )
         --c.maximized = false
      end

      if c.name == "terminal-logs" then
         c:geometry( { x = 0, y = 0 } )
         c.maximized = true
      end
    end

    -- home window layout
    if c.name and screen:count() == 3 then
      if c.name == "terminal-dropdown" then
        c:geometry( { width = 2560, height = 720, x = 1920, y = 1080 } )
        c.maximized_horizontal = true
      end

      if c.name == "terminal-notes" then
        --c:geometry( { width = 1920, height = 1080, x = 1920, y = 0 } )
        --c.maximized = true
      end

      if c.name == "terminal-devel" then
        c:geometry( { width = 2560, height = 1440, x = 1920, y = 1080 } )
        c.maximized = true
      end

      if string.find(c.name, "PyCharm") then
        c:geometry( { width = 2560, height = 1440, x = 1920, y = 1080 } )
        c.maximized = true
      end

      if string.find(c.name, "Intellij IDEA") then
        c:geometry( { width = 2560, height = 1440, x = 1920, y = 1080 } )
        c.maximized = true
      end

      if string.find(c.name, "Ulauncher") then
        mouse_coords = mouse.coords()
        current_screen = awful.screen.focused()
        x = current_screen.geometry.x + ((current_screen.geometry.width / 2) - 303)
        y = current_screen.geometry.y
        --x = mouse_coords.x
        --y = mouse_coords.y
        --max_x = (current_screen.geometry.x + current_screen.geometry.width) - 650
        --max_y = (current_screen.geometry.y + current_screen.geometry.height) - 600

        --if x > max_x then
            --x = max_x
        --end

        --if y > max_y then
            --y = max_y
        --end

        c:geometry( { x = x, y = y} )
      end

      if string.find(c.name, "Google Chrome") then
        --c:geometry( { width = 1920, height = 1080, x = 0, y = 1080 } )
        --c.maximized = true
      end

      if string.find(c.name, "SpiderOak") then
        c:geometry( { x = 0, y = 0 } )
        c:lower()
      end

      if string.find(c.name, "Slack") then
         --c:geometry( { x = 1920, y = 0, height = 1080, width = 1920 } )
         --c.maximized = false
      end

      if c.name == "terminal-logs" then
         c:geometry( { width = 2560, height = 1440, x = 1920, y = 1080 } )
         c.maximized = true
      end

      if string.find(c.name, "KeePass") then
         c:geometry( { x = 780, y = 1280, height = 1000, width = 1000 } )
      end
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 16}) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_color = beautiful.border_focus
        end
    end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Hide wibox on start
for s in screen do
    s.mywibox.ontop = true
    s.mywibox.visible = false
    if s.mybottomwibox then
        s.mybottomwibox.ontop = true
        s.mybottomwibox.visible = false
    end
end

--Startup applications
local startupApps = {"init.sh", "ulauncher", "insync start", "nm-applet", "powerline-daemon -q"}

for _, app in ipairs(startupApps) do
  awful.spawn("killall -9 " .. app)
  awful.spawn(app)
end
