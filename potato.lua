
--[[

Copyright (C) 2015 - Auke Kok <sofar@foo-projects.org>

"crops" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

local interval = crops_interval
local chance = crops_chance

minetest.register_node("crops:potato_eyes", {
	description = "potato eyes",
	inventory_image = "crops_potato_eyes.png",
	wield_image = "crops_potato_eyes.png",
	tiles = { "crops_potato_plant_1.png" },
	drawtype = "plantlike",
	sunlight_propagates = false,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	groups = { snappy=3,flammable=3,flora=1,attached_node=1 },

	on_place = function(itemstack, placer, pointed_thing)
		local under = minetest.get_node(pointed_thing.under)
		if minetest.get_item_group(under.name, "soil") <= 1 then
			return
		end
		minetest.set_node(pointed_thing.above, {name="crops:potato_plant_1"})
		if not minetest.setting_getbool("creative_mode") then
			itemstack:take_item()
		end
		return itemstack
	end
})

for stage = 1, 4 do
minetest.register_node("crops:potato_plant_" .. stage , {
	description = "potato plant",
	tiles = { "crops_potato_plant_" .. stage .. ".png" },
	drawtype = "plantlike",
	sunlight_propagates = true,
	use_texture_alpha = true,
	walkable = false,
	paramtype = "light",
	groups = { snappy=3, flammable=3, flora=1, attached_node=1, not_in_creative_inventory=1 },
	drop = {},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5,  0.5, -0.5 + (((math.min(stage, 4)) + 1) / 5), 0.5}
	}
})
end

minetest.register_craftitem("crops:potato", {
	description = "potato",
	inventory_image = "crops_potato.png",
	on_use = minetest.item_eat(1)
})

minetest.register_craft({
	type = "shapeless",
	output = "crops:potato_eyes",
	recipe = { "crops:potato" }
})

--
-- the potatoes "block"
--
minetest.register_node("crops:soil_with_potatoes", {
	description = "Soil with potatoes",
	tiles = { "default_dirt.png^crops_potato_soil.png", "default_dirt.png" },
	sunlight_propagates = false,
	use_texture_alpha = false,
	walkable = true,
	groups = { snappy=3, flammable=3, oddly_breakable_by_hand=2, soil=1 },
	paramtype2 = "facedir",
	drop = {max_items = 5, items = {
		{ items = {'crops:potato'}, rarity = 1 },
		{ items = {'crops:potato'}, rarity = 1 },
		{ items = {'crops:potato'}, rarity = 1 },
		{ items = {'crops:potato'}, rarity = 2 },
		{ items = {'crops:potato'}, rarity = 5 },
	}},
	sounds = default.node_sound_dirt_defaults(),
	on_dig = function(pos, node, digger)
		local drops = {}
		for i = 1, math.random(3, 5) do
			table.insert(drops, "crops:potato")
		end
		core.handle_node_drops(pos, drops, digger)
		minetest.set_node(pos, { name = "farming:soil" })
		local above = { x = pos.x, y = pos.y + 1, z = pos.z }
		if minetest.get_node(above).name == "crops:potato_plant_4" then
			minetest.set_node(above, { name = "air" })
		end
	end
})

--
-- grows a plant to mature size
--
minetest.register_abm({
	nodenames = { "crops:potato_plant_1", "crops:potato_plant_2", "crops:potato_plant_3" },
	neighbors = { "group:soil" },
	interval = interval,
	chance = chance,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local below = { x = pos.x, y = pos.y - 1, z = pos.z }
		if not minetest.registered_nodes[minetest.get_node(below).name].groups.soil then
			return
		end
		if minetest.get_node_light(pos, nil) < 13 then
			return
		end
		local n = string.gsub(node.name, "3", "4")
		n = string.gsub(n, "2", "3")
		n = string.gsub(n, "1", "2")
		minetest.set_node(pos, { name = n })
	end
})

--
-- grows the final potatoes in the soil beneath
--
minetest.register_abm({
	nodenames = { "crops:potato_plant_4" },
	neighbors = { "group:soil" },
	interval = interval,
	chance = chance,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if minetest.get_node_light(pos, nil) < 13 then
			return
		end
		local below = { x = pos.x, y = pos.y - 1, z = pos.z }
		if not minetest.registered_nodes[minetest.get_node(below).name].groups.soil then
			return
		end
		local below = { x = pos.x, y = pos.y - 1, z = pos.z}
		minetest.set_node(below, { name = "crops:soil_with_potatoes" })
	end
})

