-- Copyright (c) 2021 Batzhargal Ulzutuev
------------------------------------------------------------------------------
-- vector3 -like class implementation - reinvent the wheel

local calc = {}

calc.Point = {}
calc.metaPoint = {}
function calc.Point.new(a,b,c)
	local temp = { x=a or 0, y=b or 0, z=c or 0 } -- may be some perfomance issues are connected with double memory assignment or smth like this
	setmetatable(temp, calc.metaPoint)
	return temp
end

function calc.Point.rad(a)
	return (a.x^2+a.y^2+a.z^2)^0.5
end
function calc.Point.rad2(a)
	return (a.x^2+a.y^2+a.z^2)
end
function calc.Point.radxy(a)
	return (a.x^2+a.y^2)^0.5
end

function calc.Point.rev(a)
	return calc.Point.new(-a.x, -a.y, -a.z)
end

function calc.Point.sum(a, b)
	return calc.Point.new(a.x+b.x, a.y+b.y, a.z+b.z)
end

function calc.Point.sumconst(a, b)
	return calc.Point.new(a.x+b, a.y+b, a.z+b)
end

function calc.Point.prod(a, b)
	return calc.Point.new(a.x*b.x, a.y*b.y, a.z*b.z)
end

function calc.Point.prodconst(a, const)
	return calc.Point.new(a.x*const, a.y*const, a.z*const)
end
function calc.Point.scalar(a,b)
	return (a.x*b.x+a.y*b.y+a.z*b.z)
end
function calc.Point.vector(a,b)
	return calc.Point.new(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x)
end
function calc.Point.sinphi(a,b)
	local rada = calc.Point.rad(a)
	if rada==0 then return 0 end
	local radb = calc.Point.rad(b)
	if radb==0 then return 0 end
	return (calc.Point.rad(calc.Point.vector(a,b))/rada/radb)
end
function calc.Point.cosphi(a,b)
	local rada = calc.Point.rad(a)
	if rada==0 then return 0 end
	local radb = calc.Point.rad(b)
	if radb==0 then return 0 end
	return (calc.Point.scalar(a,b)/rada/radb)
end
function calc.Point.proceed(point, dx, dy, dz)
	point.x = point.x + dx
	point.y = point.y + dy
	if dz then point.z = point.z + dz end
end

calc.metaPoint.__unm = calc.Point.rev
function calc.metaPoint.__add(a, b)
	if getmetatable(a)~=calc.metaPoint then
		return calc.Point.sumconst(b,a)
	elseif getmetatable(b)~=calc.metaPoint then
		return calc.Point.sumconst(a,b)
	else
		return calc.Point.sum(a,b)
	end
end
function calc.metaPoint.__sub(a, b)
	if getmetatable(a)~=calc.metaPoint then
		return calc.Point.sumconst(-b,a)
	elseif getmetatable(b)~=calc.metaPoint then
		return calc.Point.sumconst(a,-b)
	else
		return calc.Point.sum(a,-b)
	end
end
function calc.metaPoint.__mul(a, b)
	if getmetatable(a)~=calc.metaPoint then
		return calc.Point.prodconst(b,a)
	elseif getmetatable(b)~=calc.metaPoint then
		return calc.Point.prodconst(a,b)
	else
		return calc.Point.prod(a,b)
	end
end

calc.MPoint = {}
function calc.MPoint.new(a,b)
	return { p=a or calc.Point.new(), v=b or calc.Point.new() }
end
function calc.MPoint.proceed(mpoint, deltat)
	mpoint.p.x = mpoint.p.x + mpoint.v.x*deltat
	mpoint.p.y = mpoint.p.y + mpoint.v.y*deltat
	mpoint.p.z = mpoint.p.z + mpoint.v.z*deltat
end

return calc