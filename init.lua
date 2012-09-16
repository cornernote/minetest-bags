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

-- register craftitems
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

-- register crafts
minetest.register_craft({
	output = "bags:small",
	recipe = {
        {"", "default:stick", ""},
        {"default:wood", "default:stick", "default:wood"},
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