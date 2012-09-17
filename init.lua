--[[

Bags for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-particles
License: GPLv3

MAIN LOADER

]]--


-- load api
dofile(minetest.get_modpath("bags").."/api.lua")

-- register misc
minetest.register_on_player_receive_fields(function(player, formname, fields)
	bags.on_player_receive_fields(player, formname, fields)
end)
minetest.register_on_joinplayer(function(player)
	bags.on_joinplayer(player)
end)

-- register bag craftitems
minetest.register_craftitem("bags:small", {
	description = "Small Bag",
	inventory_image = "bags_small.png",
	groups = {bagslots=8},
})
minetest.register_craftitem("bags:medium", {
	description = "Medium Bag",
	inventory_image = "bags_medium.png",
	groups = {bagslots=16},
})
minetest.register_craftitem("bags:large", {
	description = "Large Bag",
	inventory_image = "bags_large.png",
	groups = {bagslots=24},
})

-- register bag crafts
minetest.register_craft({
	output = "bags:small",
	recipe = {
        {"", "default:stick", ""},
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:wood", "default:wood"},
    },
})
minetest.register_craft({
	output = "bags:medium",
	recipe = {
        {"", "default:stick", ""},
        {"bags:small", "bags:small", "bags:small"},
        {"bags:small", "bags:small", "bags:small"},
    },
})
minetest.register_craft({
	output = "bags:large",
	recipe = {
        {"", "default:stick", ""},
        {"bags:medium", "bags:medium", "bags:medium"},
        {"bags:medium", "bags:medium", "bags:medium"},
    },
})

-- register armor
for material,name in pairs({wood="Wooden",steel_ingot="Steel",mese="Mese"}) do
	-- craftitems
	minetest.register_craftitem("bags:armor_helmet_"..material, {
		description = name.." Helmet",
		inventory_image = "armor_helmet_"..material..".png",
		groups = {armor_helmet=1},
	})
	minetest.register_craftitem("bags:armor_chest_"..material, {
		description = name.." Chestplate",
		inventory_image = "armor_chest_"..material..".png",
		groups = {armor_chest=1},
	})
	minetest.register_craftitem("bags:armor_boots_"..material, {
		description = name.." Boots",
		inventory_image = "armor_boots_"..material..".png",
		groups = {armor_boots=1},
	})
	minetest.register_craftitem("bags:armor_shield_"..material, {
		description = name.." Shield",
		inventory_image = "armor_shield_"..material..".png",
		groups = {armor_shield=1},
	})
	-- crafts
	minetest.register_craft({
		output = "bags:armor_helmet_"..material,
		recipe = {
			{"default:"..material, "default:"..material, "default:"..material},
			{"default:"..material, "", "default:"..material},
			{"default:"..material, "", "default:"..material},
		},
	})
	minetest.register_craft({
		output = "bags:armor_chest_"..material,
		recipe = {
			{"default:"..material, "default:"..material, "default:"..material},
			{"default:"..material, "default:"..material, "default:"..material},
			{"", "default:"..material, ""},
		},
	})
	minetest.register_craft({
		output = "bags:armor_boots_"..material,
		recipe = {
			{"default:"..material, "", "default:"..material},
			{"default:"..material, "", "default:"..material},
			{"default:"..material, "", "default:"..material},
		},
	})
	minetest.register_craft({
		output = "bags:armor_shield_"..material,
		recipe = {
			{"default:"..material, "default:"..material, "default:"..material},
			{"default:"..material, "", "default:"..material},
			{"default:"..material, "default:"..material, "default:"..material},
		},
	})
end
