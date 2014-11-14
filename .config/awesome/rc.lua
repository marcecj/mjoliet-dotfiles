-- vim:foldmethod=marker
--
-- TODO: display tabbed clients in a tasklist (apparently more difficult than
-- expected). Will probably involve own function to return tasklist labels.

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Vicious widgets
require("vicious")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Helper functions
function tag_client_by_group_window(c)
    local group_member = nil
    for s=1, screen.count() do
        for i=1, #tags[s] do
            local clients = tags[s][i]:clients()
            for k,v in pairs(clients) do
                if v.window ~= c.window and v.group_window == c.group_window then
                    group_member = v
                    break
                end
            end
            if group_member then break end
        end
        if group_member then break end
    end
    -- should work, but doesn't
    -- c.tags(group_member:tags())

    -- if not group_member:tags()[1].selected and client.focus == c then
    --     awful.client.focus.history.previous()
    -- end
    if group_member then
        awful.client.movetotag(group_member:tags()[1], c)
    end
    -- c:tags(group_member:tags())

    -- debug notifications
    -- naughty.notify({text = tostring(group_member:tags()[1].name),
    --                 title = "Client info:"})
end

-- TODO: would this ever be useful?
-- function tag_client_by_leader_id(c)
--     group_member = nil
--     for s=1, screen.count() do
--         for i=1, #tags[s] do
--             clients = tags[s][i]:clients()
--             for k,v in pairs(clients) do
--                 if v.window ~= c.window and v.leader_id == c.leader_id then
--                     group_member = v
--                     break
--                 end
--             end
--         end
--     end
--     -- should work, but doesn't
--     -- c.tags(group_member:tags())
--     awful.client.movetotag(group_member:tags()[1], c)
--     naughty.notify({text = tostring(group_member:tags()[1].name),
--                     title = "Client info:"})
-- end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(".config/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor
-- helper variable to give appropriate messages on activation/deactivation
screensaver_active = true

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({"D", "W", "W", "W", "E", "E", "C", "M", "A"}, s, layouts[6])
    -- set some layouts manually
    awful.layout.set(layouts[10], tags[s][1])
    awful.layout.set(layouts[1], tags[s][7])
    awful.layout.set(layouts[3], tags[s][9])
    -- set master width factors
    awful.tag.setmwfact(0.2, tags[s][7]) -- chat roster only 0.2 times the window width
    -- I'm sure you want to see at least one tag.
    tags[s][1].selected = true
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

myprogmenu = {
    {"Matlab", terminal .. " -e matlab" }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "programs", myprogmenu },
                                    { "open terminal", terminal },
                                    { "toggle redshift", "killall -USR1 redshift" }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, " %a %b %d, %H:%M ", 10)
mytextbox   = widget({ type = "textbox" })
mycpuinfo   = widget({ type = "textbox" })
mymeminfo   = widget({ type = "textbox" })
mymembar    = awful.widget.progressbar({ height = 18, width = 60})
mycpugraph  = awful.widget.graph({ height = 18, width = 60})
mynetgraph  = awful.widget.graph({ height = 18, width = 60})
mynetinfo   = widget({ type = "textbox" })

-- some text to go with some widgets
mytextbox.text = "<b><small> " .. awesome.release .. " </small></b>"
mycpuinfo.text = " CPU:"
mymeminfo.text = " MEM:"
mynetinfo.text = " NET:"

-- TODO: figure out how to center widgets vertically
-- mymembar.height = 0.85
mymembar:set_vertical(false)
mymembar:set_border_color('#0a0a0a')
mymembar:set_background_color("#333333")
mymembar:set_color("#285577")
mymembar:set_gradient_colors({ "#285577", "#AEC6D8", "#333333" })

mycpugraph:set_background_color( '#333333' )
mycpugraph:set_border_color( '#0a0a0a' )
mycpugraph:set_gradient_colors({ "#285577", "#285577", "#AEC6D8" })
mycpugraph:set_gradient_angle(180)

mynetgraph:set_background_color( '#333333' )
mynetgraph:set_border_color( '#0a0a0a' )
mynetgraph:set_gradient_colors({ "#285577", "#285577", "#AEC6D8" })
mynetgraph:set_gradient_angle(180)
mynetgraph:set_scale(true)
mynetgraph:set_stack(false)
-- mynetgraph:set_stack_colors({ '{wan0 down_kb}'="red", '{wan0 up_kb}'="blue" })

vicious.register(mymembar, vicious.widgets.mem, "$1", 1)
vicious.register(mycpugraph, vicious.widgets.cpu, '$1', 1)
-- TODO: in awesome git HEAD there is a "stacked" version allowing multiple
-- graphs in a single widget
vicious.register(mynetgraph, vicious.widgets.net, '${wan0 down_kb}', 1)
-- vicious.register(mynetgraph, vicious.widgets.net, '${wan0 down_kb} ${wan0 up_kb}', 1)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        s == 1 and mysystray or nil,
        mylayoutbox[s],
        mytextclock,
        mynetgraph.widget,
        mynetinfo,
        mycpugraph.widget,
        mycpuinfo,
        mymembar.widget,
        mymeminfo,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- lock screen / deactivate xscreensaver
    awful.key({ modkey, "Shift" }, "x",
        function ()
            -- os.execute("xscreensaver-command -lock")
            os.execute("xautolock -locknow")
        end),
    awful.key({ modkey, "Control" }, "x",
        function ()
            os.execute("xautolock -toggle")
            if screensaver_active then
                naughty.notify({text = "The screensaver has been deactivated!",
                                title = "XAutolock stopped"})
                screensaver_active = false
            else
                naughty.notify({text = "The screensaver has been reactivated!",
                                title = "XAutolock started"})
                screensaver_active = true
            end
            --[[
               [ os.execute("xscreensaver-command -exit")
               [ naughty.notify({text = "Don't forget to restart xscreensaver!",
               [                 title = "xscreensaver stopped"})
               ]]
        end),
    awful.key({ modkey,         }, "s",
        function ()
            ret = os.execute("import -display :0.0 -window root screenshot.png")
            if ret == 0 then
                naughty.notify({text = "Saved screenshot to ~/screenshot.png!",
                                title = "Screenshot saved"})
            else
                naughty.notify({text = "import failed with error " .. ret .. ".",
                                title = "Couldn't save screenshot!"})
            end
        end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize),
    awful.button({ }, 10, function (c)
                        c.maximized_horizontal = not c.maximized_horizontal
                        c.maximized_vertical   = not c.maximized_vertical
                    end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" }             , properties = { floating = true } }      ,
    { rule = { class = "mplayer2" }            , properties = { floating = true } }      ,
    { rule = { class = "mpv" }                 , properties = { floating = true } }      ,
    { rule = { class = "pinentry" }            , properties = { floating = true } }      ,
    { rule = { class = "gimp" }                , properties = { floating = true } }      ,
    { rule = { class = "Wine" }                , properties = { floating = true } }      ,
    { rule = { class = "K3b" }                 , properties = { floating = false } }     ,
    -- { rule = { class = "Okular" }              , properties = { floating = false } }     ,
    { rule = { class = "JACK" }                , properties = { floating = true } }      ,
    { rule = { class = "gv" }                  , properties = { floating = true } }      ,
    { rule = { class = "mocp" }                , properties = { floating = true } }      ,
    -- tag rules
    { rule = { class = "Firefox" }             , properties = { tag = tags[1][1] } }     ,
    { rule = { class = "Claws-mail" }          , properties = { tag = tags[1][8] } }     ,
    { rule = { class = "Gajim.py" }            , properties = { tag = tags[1][7] } }     ,
    { rule = { class = "Pidgin" }              , properties = { tag = tags[1][7] } }     ,
    { rule = { instance = "multitail-syslog" } , properties = { tag = tags[1][9] } }     ,
    { rule = { instance = "htop-sys" }         , properties = { tag = tags[1][9] } }     ,
    { rule = { class =  "com.mathworks" }      , callback = tag_client_by_group_window } ,
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    --
    -- Move clients to tag of parents.
    --

    if c.transient_for then
        c:tags(c.transient_for:tags())
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
