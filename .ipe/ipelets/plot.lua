----------------------------------------------------------------------
-- plot ipelet
----------------------------------------------------------------------
--[[

   This file is an extension of the drawing editor Ipe (ipe7.sourceforge.net)

   Copyright (c) 2009 Jan Hlavacek

   This file can be distributed and modified under the terms of the GNU General
   Public License as published by the Free Software Foundation; either version
   3, or (at your option) any later version.

   This file is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You can find a copy of the GNU General Public License at
   "http://www.gnu.org/copyleft/gpl.html", or write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

   Basic documentation (bug: better documentation needs to be written)

   All functions provided by this ipelet use a selection to describe the plot
   "viewport" on the page.  The only thing that is used from the selection is
   its bounding rectangle.  This rectangle will represent the "viewport" of the
   plot on your page. Each function will present a dialog where you, in
   addition to other things, specify the corresponding plot coordinates for
   this viewport.

   For example, assume that you start with a selection that is a rectangle.
   You choose Parametric plot, type in cos(t) and sin(t) for x and y, t from
   -3.14 to 3.14, and viewport coordinates as x from -1 to 1, y from -1 to 1.

   This will make the originally selected rectangle represent a part of
   coordinate plane with corners (-1,-1), (-1,1), (1,1) and (1,-1), and, in
   effect, draw an inscribed ellipse into the rectangle.

   There is no clipping going on right now, so if your plot is larger than the
   specified viewport, it will simply stick out of the rectangle.

   After creating a coordinate system with the "Coordinate system" menu item,
   you can use this coordinate system as your initial selection for your plots,
   and they will be correctly placed on this coordinate system.

   When creating coordinate system, you can specify location of ticks on both
   axes.  Here you can use expressions such as pi, 2*pi, etc.  If you leave
   this empty, ticks will be placed at every integer. Ticks will only be drawn
   if the tick size is not 0.

   I am planning to write a more expensive documentation for this.  In the mean
   time, if you have questions, please contact me at jhlavace@.... Also
   please contact me if you have any suggestions for improvement.

   This is my first attempt to write something in lua, and it has been put
   together quite in a hurry, so I am sure there are lot of places where things
   can be done better.

   Future plans:  Add coordinate grid generating function, make general lua
   math expressions work at other places than just tick lists (so you don't
   have to enter things like 3.14 for t), add polar plots, ...

--]]

label = "Plots"

about = [[
Parametric curves, plots of functions, coordinate systems
]]

local function isfinite(x)
   return (x > - math.huge) and (x < math.huge)
end

local function bounding_box(p)
  local box = ipe.Rect()
  for i,obj,sel,layer in p:objects() do
    if sel then box:add(p:bbox(i)) end
  end
  return box
end

local function get_number (model,string, error_msg) -- this should eventually use loadstring to parse things like "2*pi" and "arcsin(.7)" etc.
   if string == "" then
      model:warning ("You need to specify " .. error_msg)
      return
   end
   local num = tonumber(string)
   if not num then
      model:warning(string .. " is not a valid value for " .. error_msg)
      return
   end
   return num
end

-- give a vector of d, find the tridiagonal solution for spline interpolation
local function tridiag(d)
	local c, M={},{}
	local n = #d
	c[1]=1/5
	d[1]=d[1]/5
	for i=2,n-1 do
		c[i]=1/(4-c[i-1])
		d[i]=(d[i]-d[i-1])/(4-c[i-1])
	end
	d[n]=(d[n]-d[n-1])/(5-c[n-1])
	M[n+1]=d[n]
	for i=n-1,1,-1 do
		M[i+1]=d[i]-c[i]*M[i+2]
	end
	M[1]=M[2]
	M[n+2]=M[n+1]
	return M
end

-- cubic function fit
local function cubicfit(t0,t1,n,y)
	local d,p0,p1,p2,p3={},{},{},{},{}
	local h=(t1-t0)/(n-1)
	if n==2 then
		return y[1], 2.0*y[1]/3+y[2]/3.0, y[1]/3.0+y[2]*2.0/3, y[2]
	end
	for i=1,n-2 do
		d[i]= ( y[i]-2*y[i+1]+y[i+2] )*6/h^2
	end
	local M=tridiag(d)

	for i=1,n-1 do
		local a= (M[i+1]-M[i])/6/h
		local b= M[i]/2
		local c= (y[i+1]-y[i])/h - (M[i+1]+2*M[i])*h/6
		local d= y[i]
		p0[i]=d
		p1[i]=d+c*h/3
		p2[i]=d+2/3*c*h+b*h^2/3
		p3[i]=y[i+1]
	end
	return p0,p1,p2,p3
end

function curve(model)
  local box = bounding_box(model:page())
  if box:isEmpty() then
    model:warning("Selection seems to be empty")
    return
  end

  -- canvas coordinates
  local cstart = box:bottomLeft()
  local cend = box:topRight()
  local cdif = cend-cstart
  local cxlen = cdif.x
  local cylen = cdif.y

  local d = ipeui.Dialog(model.ui, "Parametric plot")
  d:add("label1", "label", {label="Enter parametric equations. Use t as a parameter."}, 1, 1, 1, 4)
  d:add("label2", "label", {label="x="}, 2, 1)
  d:add("xeq", "input", {}, 2, 2, 1, 3)
  d:add("label3", "label", {label="y="}, 3, 1)
  d:add("yeq", "input", {}, 3, 2, 1, 3)
  d:add("label4", "label", {label="Set the domain for t:"}, 4, 1, 1, 4)
  d:add("label5", "label", {label="from:"}, 5, 1, 1, 1)
  d:add("tfrom", "input", {}, 5, 2, 1, 1)
  d:add("label6", "label", {label="to:"}, 5, 3, 1, 1)
  d:add("tto", "input", {}, 5, 4, 1, 1)
  d:add("label7", "label", {label="Set coordinates for viewport:"}, 6, 1, 1, 4)
  d:add("label8", "label", {label="from x="}, 7, 1, 1, 1)
  d:add("xfrom", "input", {}, 7, 2, 1, 1)
  d:add("label9", "label", {label="to x="}, 7, 3, 1, 1)
  d:add("xto", "input", {}, 7, 4, 1, 1)
  d:add("label10", "label", {label="from y="}, 8, 1, 1, 1)
  d:add("yfrom", "input", {}, 8, 2, 1, 1)
  d:add("label11", "label", {label="to y="}, 8, 3, 1, 1)
  d:add("yto", "input", {}, 8, 4, 1, 1)
  d:add("label12", "label", {label="Enter number of samples:"}, 9, 1, 1, 2)
  d:add("n", "input", {}, 9, 3, 1, 2)
  d:add("cubic", "checkbox", {label="cubic"}, 10, 1, 1, 1)
  d:add("ok", "button", {label="&Ok", action="accept"}, 11, 4)
  d:add("cancel", "button", {label="&Cancel", action="reject"}, 11, 3)
  d:setStretch("column", 2, 1)
  d:setStretch("row", 5, 1)
  if xeqstore then d:set("xeq",xeqstore) else d:set("xeq","sin(2*pi*4*t)") end
  if yeqstore then d:set("yeq",yeqstore) else d:set("yeq","sin(2*pi*3*t+.3*pi)") end
  if x0store then d:set("xfrom",x0store) else d:set("xfrom", "-1.2") end
  if x1store then d:set("xto",x1store) else d:set("xto", "1.2") end
  if y0store then d:set("yfrom",y0store) else d:set("yfrom", "-1.2") end
  if y1store then d:set("yto",y1store) else d:set("yto", "1.2") end
  if t0store then d:set("tfrom",t0store) else d:set("tfrom", "0") end
  if t1store then d:set("tto",t1store) else d:set("tto", "1") end
  if nstore then d:set("n",nstore) else d:set("n",31) end
  if hascubicstore then d:set("cubic",cubicstore) else d:set("cubic",true) end
  if not d:execute() then return end
  local s1 = d:get("xeq")
  local s2 = d:get("yeq")
  xeqstore = s1
  yeqstore = s2
  x0store = d:get("xfrom")
  x1store = d:get("xto")
  y0store = d:get("yfrom")
  y1store = d:get("yto")
  t0store = d:get("tfrom")
  t1store = d:get("tto")
  nstore = d:get("n")
  cubicstore = d:get("cubic")
  hascubicstore = true

  -- real coordinates
  local x0 = get_number(model,x0store,"lower x limit")
  if not x0 then return end
  local x1 = get_number(model,x1store,"upper x limit")
  if not x1 then return end
  local y0 = get_number(model,y0store,"lower y limit")
  if not y0 then return end
  local y1 = get_number(model,y1store,"upper y limit")
  if not y1 then return end

  -- parameter
  local t0 = get_number(model,t0store,"initial value of t")
  if not t0 then return end
  local t1 = get_number(model,t1store,"final value of t")
  if not t1 then return end

  -- number of samples
  local n = get_number(model,nstore,"number of samples")
  if not n then return end
  if n<2 then
     model:warning("Number of samples must be at lesat 2")
     return
  end
  n = math.floor(n)

  -- check validity of t limits:
  if t0 > t1 then
     t0, t1 = t1, t0
  end
  if t0 == t1 then
     model:warning("Limits for t cannot be equal")
     return
  end

  -- check validity of x and y limits:
  if x0 > x1 then
     x0, x1 = x1, x0
  end
  if x0 == x1 then
     model:warning("Limits for x cannot be equal")
     return
  end
  if y0 > y1 then
     y0, y1 = y1, y0
  end
  if y0 == y1 then
     model:warning("Limits for y cannot be equal")
     return
  end

  -- scaling calculations
  local start = ipe.Vector(x0,y0)
  local xlen = x1-x0
  local ylen = y1-y0
  local scalem = ipe.Matrix(cxlen/xlen,0,0,cylen/ylen)
  local trans = ipe.Translation(cstart-scalem*start) * scalem
  local tlen = t1-t0
  local t = t0

  -- create user function
  local coordstr = s1 .. "," .. s2
  local mathdefs = "local abs = math.abs; local acos = math.acos; local asin = math.asin; local atan = math.atan; local atan2 = math.atan2; local ceil = math.ceil; local cos = math.cos; local cosh = math.cosh; local deg = math.deg; local exp = math.exp; local floor = math.floor; local fmod = math.fmod; local log = math.log; local log10 = math.log10; local max = math.max; local min = math.min; local modf = math.modf; local pi = math.pi; local pow = math.pow; local rad = math.rad; local sin = math.sin; local sinh = math.sinh; local sqrt = math.sqrt; local tan = math.tan; local tanh = math.tanh;"

  coordstr =  mathdefs .. "return function (t) local v = ipe.Vector(" .. coordstr .. "); return v end"
  local f,err = _G.loadstring(coordstr,"parametric_plot")
  if not f then
     model:warning("Could not compile coordinate functions")
     return
  end

  local curve = { type="curve", closed=false }

  local v0 = f()(t)
  local xs,ys={},{}
  xs[1],ys[1]=v0.x,v0.y

  v0=trans*v0
  local v1 = v0
  for i = 1,n do
     t = t + tlen/n
     v1 = f()(t)
     xs[i+1],ys[i+1]=v1.x,v1.y
     v1 = trans*v1
     curve[#curve + 1] = { type="segment", v0, v1 }
     v0 = v1
  end

  local graph = ipe.Path(model.attributes, { curve } )

   -- if want cubic interpolation
   local spline= { type="curve", closed=false }
   if cubicstore==true then
    local p0x,p1x,p2x,p3x=cubicfit(t0,t1,n+1,xs)
    local p0y,p1y,p2y,p3y=cubicfit(t0,t1,n+1,ys)
	for i=1,n do
		spline[#spline+1]={ type="bezier",
			trans*ipe.Vector(p0x[i], p0y[i]),
			trans*ipe.Vector(p1x[i], p1y[i]),
			trans*ipe.Vector(p2x[i], p2y[i]),
			trans*ipe.Vector(p3x[i], p3y[i]) }
	end
	graph = ipe.Path(model.attributes, { spline } )
   end

  model:creation("create graph", graph)
end

function func_plot(model)
   local box = bounding_box(model:page())
   if box:isEmpty() then
      model:warning("Selection seems to be empty")
      return
   end

   -- canvas coordinates
   local cstart = box:bottomLeft()
   local cend = box:topRight()
   local cdif = cend-cstart
   local cxlen = cdif.x
   local cylen = cdif.y

   local d = ipeui.Dialog(model.ui, "Function Plot")
   d:add("label1", "label", {label="Enter y as a function of x"}, 1, 1, 1, 4)
   d:add("label2", "label", {label="y="}, 2, 1)
   d:add("xeq", "input", {}, 2, 2, 1, 3)
   d:add("label4", "label", {label="Set the domain for x:"}, 3, 1, 1, 4)
   d:add("label5", "label", {label="from:"}, 4, 1, 1, 1)
   d:add("tfrom", "input", {}, 4, 2, 1, 1)
   d:add("label6", "label", {label="to:"}, 4, 3, 1, 1)
   d:add("tto", "input", {}, 4, 4, 1, 1)
   d:add("label7", "label", {label="Set coordinates for viewport:"}, 5, 1, 1, 4)
   d:add("label8", "label", {label="from x="}, 6, 1, 1, 1)
   d:add("xfrom", "input", {}, 6, 2, 1, 1)
   d:add("label9", "label", {label="to x="}, 6, 3, 1, 1)
   d:add("xto", "input", {}, 6, 4, 1, 1)
   d:add("label10", "label", {label="from y="}, 7, 1, 1, 1)
   d:add("yfrom", "input", {}, 7, 2, 1, 1)
   d:add("label11", "label", {label="to y="}, 7, 3, 1, 1)
   d:add("yto", "input", {}, 7, 4, 1, 1)
   d:add("label12", "label", {label="Enter number of samples:"}, 8, 1, 1, 2)
   d:add("n", "input", {}, 8, 3, 1, 2)
   d:add("cubic", "checkbox", {label="&cubic"}, 9, 1, 1, 2)
   d:add("ok", "button", {label="&Ok", action="accept"}, 10, 4)
   d:add("cancel", "button", {label="&Cancel", action="reject"}, 10, 3)
   d:setStretch("column", 2, 1)
   d:setStretch("row", 5, 1)
   if fstore then d:set("xeq",fstore)
   	else d:set("xeq","cos(2*pi*4*x)*exp(-abs(3*x))") end
   if x0store then d:set("xfrom",x0store) else d:set("xfrom", "-1.2") end
   if x1store then d:set("xto",x1store) else d:set("xto", "1.2") end
   if y0store then d:set("yfrom",y0store) else d:set("yfrom", "-1.2") end
   if y1store then d:set("yto",y1store) else d:set("yto", "1.2") end
   if dom0store then d:set("tfrom",dom0store) else d:set("tfrom", "-1.2") end
   if dom1store then d:set("tto",dom1store) else d:set("tto", "1.2") end
   if nstore then d:set("n",nstore) else d:set("n",31) end
   if hascubicstore then d:set("cubic",cubicstore) else d:set("cubic",true) end
   if not d:execute() then return end
   local s1 = d:get("xeq")
   fstore = s1
   x0store = d:get("xfrom")
   x1store = d:get("xto")
   y0store = d:get("yfrom")
   y1store = d:get("yto")
   dom0store = d:get("tfrom")
   dom1store = d:get("tto")
   nstore = d:get("n")
   cubicstore = d:get("cubic")
   hascubicstore = true

   -- real coordinates
   local x0 = get_number(model,x0store,"lower x limit")
   if not x0 then return end
   local x1 = get_number(model,x1store,"upper x limit")
   if not x1 then return end
   local y0 = get_number(model,y0store,"lower y limit")
   if not y0 then return end
   local y1 = get_number(model,y1store,"upper y limit")
   if not y1 then return end

   -- independent variable
   local t0 = get_number(model,dom0store,"initial value of x")
   if not t0 then return end
   local t1 = get_number(model,dom1store,"final value of x")
   if not t1 then return end

   -- number of samples
   local n = get_number(model,nstore,"number of samples")
   if not n then return end
   if n<2 then
      model:warning("Number of samples must be at lesat 2")
      return
   end
   n = math.floor(n)

   -- check validity of t limits:
   if t0 > t1 then
      t0, t1 = t1, t0
   end
   if t0 == t1 then
      model:warning("Limits for x cannot be equal")
      return
   end

   -- check validity of x and y limits:
   if x0 > x1 then
      x0, x1 = x1, x0
   end
   if x0 == x1 then
      model:warning("Limits for x cannot be equal")
      return
   end
   if y0 > y1 then
      y0, y1 = y1, y0
   end
   if y0 == y1 then
      model:warning("Limits for y cannot be equal")
      return
   end

   -- scaling calculations
   local start = ipe.Vector(x0,y0)
   local xlen = x1-x0
   local ylen = y1-y0
   local scalem = ipe.Matrix(cxlen/xlen,0,0,cylen/ylen)
   local trans = ipe.Translation(cstart-scalem*start) * scalem
   local tlen = t1-t0
   local t = t0

   -- create user function
   local coordstr = s1
   local mathdefs = "local abs = math.abs; local acos = math.acos; local asin = math.asin; local atan = math.atan; local atan2 = math.atan2; local ceil = math.ceil; local cos = math.cos; local cosh = math.cosh; local deg = math.deg; local exp = math.exp; local floor = math.floor; local fmod = math.fmod; local log = math.log; local log10 = math.log10; local max = math.max; local min = math.min; local modf = math.modf; local pi = math.pi; local pow = math.pow; local rad = math.rad; local sin = math.sin; local sinh = math.sinh; local sqrt = math.sqrt; local tan = math.tan; local tanh = math.tanh;"

   coordstr =  mathdefs .. "return function (x) local v = ipe.Vector(x," .. coordstr .. "); return v end"
   -- attempt to load this string.  Give a warning and quit if it fails.
   local f,err = _G.loadstring(coordstr,"function plot")
   if not f then
      model:warning(err) -- bug: error messages will be cryptic
      return
   end
   -- execute the function obtained from the string.  That should create the
   -- actual function usable for our calculations.  Warn and quit if it fails.
   stat,f = _G.pcall(f)
   if not stat then
      model:warning(f) -- bug: error messages will be cryptic
      return
   end

   local curve = { type="curve", closed=false }
   local v0
   -- try to evaluate the function.  Warn and quit if it fails.
   stat, v0 = _G.pcall(f,t)
   if not stat then
	  model:warning(v0) -- bug: error messages will be cryptic
	  return
   end
   if not isfinite(v0.x*v0.y) then
	  model:warning("domain error")
	  return
   end

   local ys={}
   ys[1]=v0.y

   v0 = trans*v0
   local v1 = v0
   n=n-1
   for i = 1,n do
	  t = t + tlen/n
	  stat, v1 = _G.pcall(f,t)
	  if not stat then
		 model:warning(v1) -- bug: error messages will be cryptic
		 return
	  end
	  if not isfinite(v1.x*v1.y) then
		 model:warning("domain error")
		 return
	  end

      ys[i+1]=v1.y
	  v1 = trans*v1
	  curve[#curve + 1] = { type="segment", v0, v1 }
	  v0 = v1
   end

   local graph = ipe.Path(model.attributes, { curve } )

   -- if want cubic interpolation
   local spline= { type="curve", closed=false }
   if cubicstore==true then
    local p0,p1,p2,p3=cubicfit(t0,t1,n+1,ys)
	local h=tlen/n
	local t=t0
	for i=1,n do
		spline[#spline+1]={ type="bezier",
			trans*ipe.Vector(t, p0[i]),
			trans*ipe.Vector(t+h/3, p1[i]),
			trans*ipe.Vector(t+2*h/3, p2[i]),
			trans*ipe.Vector(t+h, p3[i]) }
		t=t+h
	end
	graph = ipe.Path(model.attributes, { spline } )
   end

   model:creation("create graph", graph)
end

function make_axes(model)
   local box = bounding_box(model:page())
   if box:isEmpty() then
      model:warning("Selection seems to be empty")
      return
   end

   -- canvas coordinates
   local cstart = box:bottomLeft()
   local cend = box:topRight()
   local cdif = cend-cstart
   local cxlen = cdif.x
   local cylen = cdif.y

   local d = ipeui.Dialog(model.ui, "Coordinate System")
   d:add("label3", "label", {label="Set coordinates for viewport:"}, 1, 1, 1, 4)
   d:add("label8", "label", {label="from x="}, 2, 1, 1, 1)
   d:add("xfrom", "input", {}, 2, 2, 1, 1)
   d:add("label9", "label", {label="to x="}, 2, 3, 1, 1)
   d:add("xto", "input", {}, 2, 4, 1, 1)
   d:add("label10", "label", {label="from y="}, 3, 1, 1, 1)
   d:add("yfrom", "input", {}, 3, 2, 1, 1)
   d:add("label11", "label", {label="to y="}, 3, 3, 1, 1)
   d:add("yto", "input", {}, 3, 4, 1, 1)
   d:add("label27", "label", {label="Size of x-ticks (in pt):"}, 4, 1, 1, 1)
   d:add("xticksize", "input", {}, 4, 2, 1, 1)
   d:add("label28", "label", {label="Size of y-ticks (in pt):"}, 4, 3, 1, 1)
   d:add("yticksize", "input", {}, 4, 4, 1, 1)
   d:add("label84", "label", {label="Locations of x-ticks:"},5,1,1,1)
   d:add("xticklist", "input", {}, 5, 2, 1, 3)
   d:add("label85", "label", {label="Locations of y-ticks:"},6,1,1,1)
   d:add("yticklist", "input", {}, 6, 2, 1, 3)
   d:add("ok", "button", {label="&Ok", action="accept"}, 7, 4)
   d:add("cancel", "button", {label="&Cancel", action="reject"}, 7, 3)
   d:setStretch("column", 2, 1)
   d:setStretch("row", 5, 1)
   if x0store then d:set("xfrom",x0store) end
   if x1store then d:set("xto",x1store) end
   if y0store then d:set("yfrom",y0store) end
   if y1store then d:set("yto",y1store) end
   if not xticksizestore then xticksizestore = 0 end
   d:set("xticksize", xticksizestore)
   if not yticksizestore then yticksizestore = 0 end
   d:set("yticksize", yticksizestore)
   if xticksstore then d:set("xticklist", xtickstore) end
   if yticksstore then d:set("yticklist", ytickstore) end
   if not d:execute() then return end
   x0store = d:get("xfrom")
   x1store = d:get("xto")
   y0store = d:get("yfrom")
   y1store = d:get("yto")
   xticksizestore = d:get("xticksize")
   yticksizestore = d:get("yticksize")
   xtickstore = d:get("xticklist")
   ytickstore = d:get("yticklist")

   -- real coordinates
   local x0 = get_number(model,x0store,"lower x limit")
   if not x0 then return end
   local x1 = get_number(model,x1store,"upper x limit")
   if not x1 then return end
   local y0 = get_number(model,y0store,"lower y limit")
   if not y0 then return end
   local y1 = get_number(model,y1store,"upper y limit")
   if not y1 then return end

   -- check validity of x and y limits:
   if x0 > x1 then
      x0, x1 = x1, x0
   end
   if x0 == x1 then
      model:warning("Limits for x cannot be equal")
      return
   end
   if y0 > y1 then
      y0, y1 = y1, y0
   end
   if y0 == y1 then
      model:warning("Limits for y cannot be equal")
      return
   end

   -- scaling calculations
   local start = ipe.Vector(x0,y0)
   local xlen = x1-x0
   local ylen = y1-y0
   local scalem = ipe.Matrix(cxlen/xlen,0,0,cylen/ylen)
   local trans = ipe.Translation(cstart-scalem*start) * scalem

   -- ticks:
   xticksize = tonumber(xticksizestore)
   if not xticksize then xticksize = 0 end
   yticksize = tonumber(yticksizestore)
   if not yticksize then yticksize = 0 end

   -- tick locations:
   local mathdefs = "local abs = math.abs; local acos = math.acos; local asin = math.asin; local atan = math.atan; local atan2 = math.atan2; local ceil = math.ceil; local cos = math.cos; local cosh = math.cosh; local deg = math.deg; local exp = math.exp; local floor = math.floor; local fmod = math.fmod; local log = math.log; local log10 = math.log10; local max = math.max; local min = math.min; local modf = math.modf; local pi = math.pi; local pow = math.pow; local rad = math.rad; local sin = math.sin; local sinh = math.sinh; local sqrt = math.sqrt; local tan = math.tan; local tanh = math.tanh;"

   local xticks = {}
   local yticks = {}

   if xtickstore and (xtickstore ~= "") then
      local tickliststr = mathdefs .. "return {" .. xtickstore .. "}"
      -- attempt to load this string.  Give a warning and quit if it fails.
      local f,err = _G.loadstring(tickliststr,"x-ticks")
      if not f then
         model:warning(err) -- bug: error messages will be cryptic
         return
      end
      local xticklist
      stat, xticklist = _G.pcall(f,t)
      if not stat then
         model:warning(xticklist) -- bug: error messages will be cryptic
         return
      end
      for i,x in pairs(xticklist) do
         if isfinite(x) then
            if (x > x0) and (x < x1) then
               xticks[#xticks + 1] = x
            end
         end
      end
   else -- place ticks at every integer
      for i = math.floor(x0) + 1, math.ceil(x1)-1 do
         xticks[#xticks + 1] = i
      end
   end

   -- do the same for y-ticks
   if ytickstore and (ytickstore ~= "") then
      local tickliststr = mathdefs .. "return {" .. ytickstore .. "}"
      -- attempt to load this string.  Give a warning and quit if it fails.
      local f,err = _G.loadstring(tickliststr,"y-ticks")
      if not f then
         model:warning(err) -- bug: error messages will be cryptic
         return
      end
      local yticklist
      stat, yticklist = _G.pcall(f,t)
      if not stat then
         model:warning(yticklist) -- bug: error messages will be cryptic
         return
      end
      for i,y in pairs(yticklist) do
         if isfinite(y) then
            if (y > y0) and (y < y1) then
               yticks[#yticks + 1] = y
            end
         end
      end
   else -- place ticks at every integer
      for i = math.floor(y0) + 1, math.ceil(y1)-1 do
         yticks[#yticks + 1] = i
      end
   end

   local axes = { }

   -- only make x-axis if y0<=0<=y1
   if y0*y1 <= 0 then
      local v0 = trans*ipe.Vector(x0,0)
      local v1 = trans*ipe.Vector(x1,0)
      local curve = { type="curve", closed=false; { type="segment", v0, v1 }}
      local xaxis = ipe.Path(model.attributes, {curve})
      xaxis:set("farrow",true)
      xaxis:set("pen","fat")
      axes[#axes + 1] = xaxis
      if xticksize ~= 0 then
         local half_tick = ipe.Vector(0,xticksize/2)
         for n,i in pairs(xticks) do
            v0 = trans*ipe.Vector(i,0)
            local tick = { type="curve", closed=false; { type="segment", v0+half_tick, v0-half_tick }}
            axes[#axes + 1] = ipe.Path(model.attributes, {tick})
         end
      end
   end
   if x0*x1 <= 0 then
      local v0 = trans*ipe.Vector(0,y0)
      local v1 = trans*ipe.Vector(0,y1)
      curve = { type="curve", closed=false; { type="segment", v0, v1 }}
      local yaxis = ipe.Path(model.attributes, {curve})
      yaxis:set("farrow",true)
      yaxis:set("pen","fat")
      axes[#axes + 1] = yaxis
      if yticksize ~= 0 then
         local half_tick = ipe.Vector(yticksize/2,0)
         for n,i in pairs(yticks) do
            v0 = trans*ipe.Vector(0,i)
            local tick = { type="curve", closed=false; { type="segment", v0+half_tick, v0-half_tick }}
            axes[#axes + 1] = ipe.Path(model.attributes, {tick})
         end
      end
   end

   if #axes > 0 then
      local coordsys = ipe.Group(axes)
      model:creation("create coordinate system", coordsys)
   end
end

methods = {
   { label = "Parametric plot", run=curve },
   { label = "Function plot", run=func_plot },
   { label = "Coordinate system", run=make_axes },
}

----------------------------------------------------------------------
