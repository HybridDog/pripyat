minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
end)

minetest.register_node("pyripat:undigable", {
	drawtype = "airlike",
	pointable = false,
	groups = {no=1},
	drop = "",
})

local c_undigable = minetest.get_content_id("pyripat:undigable")

local function generate_chunk(minp, maxp, seed, generated)
	if minp.y >= 10 then --avoid big map generation
		return
	end

	local vm, emin, emax, data, area
	if generated then
		vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	else
		vm = minetest.get_voxel_manip()
		local emerged_pos1, emerged_pos2 = vm:read_from_map(minp, maxp)
		area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	end
	data = vm:get_data()

	--pr = PseudoRandom(seed+33)

	for y = minp.y, maxp.y do
		if y == -8 then
			for z = minp.z, maxp.z do
				for x = minp.x, maxp.x do
					data[area:index(x, y, z)] = c_undigable
				end
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
	if not generated then
		vm:update_map()
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	generate_chunk(minp, maxp, seed, true)
end)

local mchunksize = 16*5
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 2 then
		for _,player in pairs(minetest.get_connected_players()) do
			local pos = vector.round(player:getpos())
			if pos.y < -8 then
				player:moveto({x=pos.x, y=20, z=pos.z})
			end
			if minetest.get_node({x=pos.x, y=-8, z=pos.z}).name ~= "pyripat:undigable" then
				local minp = {x=pos.x-pos.x%mchunksize, y=-mchunksize, z=pos.z-pos.z%mchunksize}
				local maxp = vector.add(minp, mchunksize-1)
				generate_chunk(minp, maxp)
				--minetest.chat_send_all("changing map")
			end
		end
		timer = 0
	end
end)

