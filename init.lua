minetest.register_on_mapgen_init(function(mgparams)
	minetest.set_mapgen_params({mgname="singlenode"})
end)

local c_stone = minetest.get_content_id("default:stone")

minetest.register_on_generated(function(minp, maxp, seed)
	if minp.y >= 10 then --avoid big map generation
		return
	end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	pr = PseudoRandom(seed+33)

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				if y <= -8 then
					data[area:index(x, y, z)] = c_stone
				end
			end
		end
	end

	vm:set_data(data)
--	vm:set_lighting(12)
--	vm:calc_lighting()
--	vm:update_liquids()
	vm:write_to_map()
end)
