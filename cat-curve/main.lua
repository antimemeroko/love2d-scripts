-- Copyright (c) 2021 Batzhargal Ulzutuev
------------------------------------------------------------------------------
--

--print(package.path)

-- this can be a problem if package.path is constantly updated, see
-- https://medium.com/@fabricebaumann/how-we-reduced-the-cpu-usage-of-our-lua-code-cc30d001a328

-- package.path = ";../?.lua" .. package.path doesn't work for some reason

package.path = package.path .. ";../?.lua"

local vector3d = require "vector3d"
local Point = vector3d.Point
local Pi = math.pi
local sin = math.sin
local abs = math.abs
local exp = math.exp
local rand = math.random
function love.load()
	time = 0
	love.window.setFullscreen(true)
	love.mouse.setVisible(false)
	
	width, height = love.graphics.getDimensions()
	function setBGColor(p)
		love.graphics.setBackgroundColor(p.x, p.y, p.z)
	end
	function setColor(p)
		love.graphics.setColor(p.x, p.y, p.z)
	end
	color = Point.new(127,127,127)

	sendTime = false
	funcShader = love.graphics.newShader[[
		#define PI 3.1415926538
		#define catLength 100
		uniform float width = 800.0;
		uniform float height = 600.0;
		//uniform float time = 0.0;
		uniform float focus = 1.0;
		uniform float xmin = -1.0;
		uniform float ymin = -1.0;
		uniform float xmax = 1.0;
		uniform float ymax = 1.0;

		mat2 rot(float phi){ //columns first, then rows
			return mat2(cos(phi), -sin(phi), sin(phi), cos(phi));
		}

		vec2 catCurve(float t){
			// source: https://www.wolframalpha.com/input/?i=first+kitty+curve
			float x = -(721*sin(t))/4 + 196/3*sin(2*t) - 86/3*sin(3*t) - 131/2*sin(4*t) + 477/14*sin(5*t) + 27*sin(6*t) - 29/2*sin(7*t) + 68/5*sin(8*t) + 0.1*sin(9*t) + 23/4*sin(10*t) - 19/2*sin(12*t) - 85/21*sin(13*t) + 2/3*sin(14*t) + 27/5*sin(15*t) + 7/4*sin(16*t) + 17/9*sin(17*t) - 4*sin(18*t) - 0.5*sin(19*t) + 1/6*sin(20*t) + 6/7*sin(21*t) - 0.125*sin(22*t) + 1/3*sin(23*t) + 1.5*sin(24*t) + 13/5*sin(25*t) + sin(26*t) - 2*sin(27*t) + 0.6*sin(28*t) - 0.2*sin(29*t) + 0.2*sin(30*t) + (2337*cos(t))/8 - 43/5*cos(2*t) + 322/5*cos(3*t) - 117/5*cos(4*t) - 26/5*cos(5*t) - 23/3*cos(6*t) + 143/4*cos(7*t) - 11/4*cos(8*t) - 31/3*cos(9*t) - 13/4*cos(10*t) - 4.5*cos(11*t) + 41/20*cos(12*t) + 8*cos(13*t) + 2/3*cos(14*t) + 6*cos(15*t) + 17/4*cos(16*t) - 1.5*cos(17*t) - 2.9*cos(18*t) + 11/6*cos(19*t) + 2.4*cos(20*t) + 1.5*cos(21*t) + 11/12*cos(22*t) - 0.8*cos(23*t) + cos(24*t) + 17/8*cos(25*t) - 3.5*cos(26*t) - 5/6*cos(27*t) - 11/10*cos(28*t) + 0.5*cos(29*t) - 0.2*cos(30*t);
			float y = -(637*sin(t))/2 - 188/5*sin(2*t) - 11/7*sin(3*t) - 2.4*sin(4*t) + 11/3*sin(5*t) - 37/4*sin(6*t) + 8/3*sin(7*t) + 65/6*sin(8*t) - 32/5*sin(9*t) - 41/4*sin(10*t) - 38/3*sin(11*t) - 47/8*sin(12*t) + 5/4*sin(13*t) - 41/7*sin(14*t) - 7/3*sin(15*t) - 13/7*sin(16*t) + 17/4*sin(17*t) - 9/4*sin(18*t) + 8/9*sin(19*t) + 0.6*sin(20*t) - 2/5*sin(21*t) + 4/3*sin(22*t) + 1/3*sin(23*t) + 0.6*sin(24*t) - 0.6*sin(25*t) + 1.2*sin(26*t) - 0.2*sin(27*t) + 10/9*sin(28*t) + 1/3*sin(29*t) - 0.75*sin(30*t) - (125*cos(t))/2 - 521/9*cos(2*t) - 359/3*cos(3*t) + 47/3*cos(4*t) - 33/2*cos(5*t) - 1.25*cos(6*t) + 31/8*cos(7*t) + 0.9*cos(8*t) - 119/4*cos(9*t) - 17/2*cos(10*t) + 22/3*cos(11*t) + 15/4*cos(12*t) - 2.5*cos(13*t) + 19/6*cos(14*t) + 7/4*cos(15*t) + 31/4*cos(16*t) - cos(17*t) + 1.1*cos(18*t) - 2/3*cos(19*t) + 13/3*cos(20*t) - 1.25*cos(21*t) + 2/3*cos(22*t) + 0.25*cos(23*t) + 5/6*cos(24*t) + 0.75*cos(26*t) - 0.5*cos(27*t) - 0.1*cos(28*t) - 1/3*cos(29*t) - 1/19*cos(30*t);
			return vec2(x, -y);
		}

		float f(float x, float y){
			float temp = length(catCurve(0));
			vec2 tmp = vec2(x, y);
			
			for (int i = 1; i < catLength; ++i) {
				vec2 cat = catCurve(2*PI*i/catLength);
				temp = min(temp, distance(cat, tmp));
			}
			
			return temp;
		}
		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			float x = xmin + (xmax-xmin)*screen_coords[0]/width;
			float y = ymin + (ymax-ymin)*screen_coords[1]/height;

			float alpha = f(x, y);

			vec4 pixel;
			pixel.r = atan(focus/alpha)*2/PI;
			pixel.g = atan(focus/alpha/alpha)*2/PI;
			pixel.b = atan(focus*exp(-alpha*alpha))*2/PI;
			pixel.a = 1.0;
	
			return pixel * color;
		}
	]]
	funcShader:send("width", width)
	funcShader:send("height", height)
	coef = 1e2 --focus
	delta = 1e3
	cntr = Point.new(0,0)
	xmin = cntr.x-delta
	xmax = cntr.x+delta
	ymin = cntr.y-delta*height/width
	ymax = cntr.y+delta*height/width
	dx = 1
	dy = 1
	x, y = 0, 0
end

function love.keypressed(key)
	keyPressed = key
end

function love.keyreleased(key)
	if key==keyPressed then keyPressed = '' end
end

function love.wheelmoved(_x,_y)
	coef = coef*math.exp(_y/2)
end


function love.update(dt)
	time = time + dt
	if keyPressed=='b' then
		local screenshot = love.graphics.newScreenshot()
		local str = os.time() .. '.png'
   		screenshot:encode('png', str)
   	end
end

function love.draw()
	love.graphics.setShader(funcShader) --draw something here
		if sendTime then funcShader:send("time", time) end
		funcShader:send("focus", coef)
		funcShader:send("xmin", xmin)
		funcShader:send("xmax", xmax)
		funcShader:send("ymin", ymin)
		funcShader:send("ymax", ymax)
		setColor(Point.new(255,255,255))
		love.graphics.rectangle('fill', 0, 0, width, height)
  	love.graphics.setShader()
end