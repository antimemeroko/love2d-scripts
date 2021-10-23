-- Copyright (c) 2021 Batzhargal Ulzutuev
------------------------------------------------------------------------------
-- vector3-like class implementation - reinvent the wheel

local vector3d = {}

vector3d.Point = {}
vector3d.metaPoint = {}
function vector3d.Point.new(a,b,c)
	local temp = { x=a or 0, y=b or 0, z=c or 0 } -- may be some perfomance issues are connected with double memory assignment or smth like this
	setmetatable(temp, vector3d.metaPoint)
	return temp
end

function vector3d.Point.rad(a)
	return (a.x^2+a.y^2+a.z^2)^0.5
end
function vector3d.Point.rad2(a)
	return (a.x^2+a.y^2+a.z^2)
end
function vector3d.Point.radxy(a)
	return (a.x^2+a.y^2)^0.5
end

function vector3d.Point.rev(a)
	return vector3d.Point.new(-a.x, -a.y, -a.z)
end

function vector3d.Point.sum(a, b)
	return vector3d.Point.new(a.x+b.x, a.y+b.y, a.z+b.z)
end

function vector3d.Point.sumconst(a, b)
	return vector3d.Point.new(a.x+b, a.y+b, a.z+b)
end

function vector3d.Point.prod(a, b)
	return vector3d.Point.new(a.x*b.x, a.y*b.y, a.z*b.z)
end

function vector3d.Point.prodconst(a, const)
	return vector3d.Point.new(a.x*const, a.y*const, a.z*const)
end
function vector3d.Point.scalar(a,b)
	return (a.x*b.x+a.y*b.y+a.z*b.z)
end
function vector3d.Point.vector(a,b)
	return vector3d.Point.new(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x)
end
function vector3d.Point.sinphi(a,b)
	local rada = vector3d.Point.rad(a)
	if rada==0 then return 0 end
	local radb = vector3d.Point.rad(b)
	if radb==0 then return 0 end
	return (vector3d.Point.rad(vector3d.Point.vector(a,b))/rada/radb)
end
function vector3d.Point.cosphi(a,b)
	local rada = vector3d.Point.rad(a)
	if rada==0 then return 0 end
	local radb = vector3d.Point.rad(b)
	if radb==0 then return 0 end
	return (vector3d.Point.scalar(a,b)/rada/radb)
end
function vector3d.Point.proceed(point, dx, dy, dz)
	point.x = point.x + dx
	point.y = point.y + dy
	if dz then point.z = point.z + dz end
end

vector3d.metaPoint.__unm = vector3d.Point.rev
function vector3d.metaPoint.__add(a, b)
	if getmetatable(a)~=vector3d.metaPoint then
		return vector3d.Point.sumconst(b,a)
	elseif getmetatable(b)~=vector3d.metaPoint then
		return vector3d.Point.sumconst(a,b)
	else
		return vector3d.Point.sum(a,b)
	end
end
function vector3d.metaPoint.__sub(a, b)
	if getmetatable(a)~=vector3d.metaPoint then
		return vector3d.Point.sumconst(-b,a)
	elseif getmetatable(b)~=vector3d.metaPoint then
		return vector3d.Point.sumconst(a,-b)
	else
		return vector3d.Point.sum(a,-b)
	end
end
function vector3d.metaPoint.__mul(a, b)
	if getmetatable(a)~=vector3d.metaPoint then
		return vector3d.Point.prodconst(b,a)
	elseif getmetatable(b)~=vector3d.metaPoint then
		return vector3d.Point.prodconst(a,b)
	else
		return vector3d.Point.prod(a,b)
	end
end

vector3d.MPoint = {}
function vector3d.MPoint.new(a,b)
	return { p=a or vector3d.Point.new(), v=b or vector3d.Point.new() }
end
function vector3d.MPoint.proceed(mpoint, deltat)
	mpoint.p.x = mpoint.p.x + mpoint.v.x*deltat
	mpoint.p.y = mpoint.p.y + mpoint.v.y*deltat
	mpoint.p.z = mpoint.p.z + mpoint.v.z*deltat
end

return vector3d