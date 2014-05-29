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

	pr = PseudoRandom(seed+33)

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
		manip:update_map()
	end
end

minetest.register_on_generated(function(minp, maxp, seed)
	generate_chunk(minp, maxp, seed, true)
end)
