--[[

Bags for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-particles
License: GPLv3

]]--


-- get_formspec
local get_formspec = function(player,page)
	if page=="bags" then
		return "size[8,7.5]"
			.."list[current_player;main;0,3.5;8,4;]"
			.."button[0,0;2,0.5;main;Back]"
			.."button[0,2;2,0.5;bag1;Bag 1]"
			.."button[2,2;2,0.5;bag2;Bag 2]"
			.."button[4,2;2,0.5;bag3;Bag 3]"
			.."button[6,2;2,0.5;bag4;Bag 4]"
			.."list[detached:"..player:get_player_name().."_bags;bag1;0.5,1;1,1;]"
			.."list[detached:"..player:get_player_name().."_bags;bag2;2.5,1;1,1;]"
			.."list[detached:"..player:get_player_name().."_bags;bag3;4.5,1;1,1;]"
			.."list[detached:"..player:get_player_name().."_bags;bag4;6.5,1;1,1;]"
	end
	for i=1,4 do
		if page=="bag"..i then
			local image = player:get_inventory():get_stack("bag"..i, 1):get_definition().inventory_image
			return "size[8,8.5]"
				.."list[current_player;main;0,4.5;8,4;]"
				.."button[0,0;2,0.5;main;Main]"
				.."button[2,0;2,0.5;bags;Bags]"
				.."image[7,0;1,1;"..image.."]"
				.."list[current_player;bag"..i.."contents;0,1;8,3;]"
		end
	end
end

-- register_on_player_receive_fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.bags then
		inventory_plus.set_inventory_formspec(player, get_formspec(player,"bags"))
		return
	end
	for i=1,4 do
		local page = "bag"..i
		if fields[page] then
			if player:get_inventory():get_stack(page, 1):get_definition().groups.bagslots==nil then
				page = "bags"
			end
			inventory_plus.set_inventory_formspec(player, get_formspec(player,page))
			return
		end
	end
end)

-- register_on_joinplayer
minetest.register_on_joinplayer(function(player)
	inventory_plus.register_button(player,"bags","Bags")
	local player_inv = player:get_inventory()
	local bags_inv = minetest.create_detached_inventory(player:get_player_name().."_bags",{
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			player:get_inventory():set_size(listname.."contents", stack:get_definition().groups.bagslots)
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
		end,
		allow_put = function(inv, listname, index, stack, player)
			if stack:get_definition().groups.bagslots then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			if player:get_inventory():is_empty(listname.."contents")==true then
				return stack:get_count()
			else
				return 0
			end
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
	})
	for i=1,4 do
		local bag = "bag"..i
		player_inv:set_size(bag, 1)
		bags_inv:set_size(bag, 1)
		bags_inv:set_stack(bag,1,player_inv:get_stack(bag,1))
	end
end)

-- register bag tools
minetest.register_tool("bags:small", {
	description = "Small Bag",
	inventory_image = "bags_small.png",
	groups = {bagslots=8},
})
minetest.register_tool("bags:medium", {
	description = "Medium Bag",
	inventory_image = "bags_medium.png",
	groups = {bagslots=16},
})
minetest.register_tool("bags:large", {
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

-- log that we started
minetest.log("action", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))