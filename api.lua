--[[

Bags for Minetest

Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Source Code: https://github.com/cornernote/minetest-particles
License: GPLv3

API

]]--


-- expose api
bags = {}


-- get_formspec
bags.get_formspec = function(player,page)
	local formspec = "size[8,8.5]"
		.."list[current_player;main;0,3.5;8,4;]"
		.."button[0,7.8;2,0.5;main;Main]"
		.."button[2,7.8;2,0.5;bags;Bags]"

	-- creative button
	if minetest.setting_getbool("creative_mode") then
		formspec = formspec .. "button[6,7.8;2,0.5;creative;Creative]"
	end
	
	-- bags
	if page=="bags" then
		return formspec
			.."button[0,2;2,0.5;bag1;Bag 1]"
			.."list[detached:"..player:get_player_name().."_bags;bag1;0.5,1;1,1;]"
			
			.."button[2,2;2,0.5;bag2;Bag 2]"
			.."list[detached:"..player:get_player_name().."_bags;bag2;2.5,1;1,1;]"

			.."button[4,2;2,0.5;bag3;Bag 3]"
			.."list[detached:"..player:get_player_name().."_bags;bag3;4.5,1;1,1;]"

			.."button[6,2;2,0.5;bag4;Bag 4]"
			.."list[detached:"..player:get_player_name().."_bags;bag4;6.5,1;1,1;]"
	end

	-- bag
	for i=1,4 do
		if page=="bag"..i then
			local image = player:get_inventory():get_stack("bag"..i, 1):get_definition().inventory_image
			return formspec
				.."image[0,0;1,1;"..image.."]"
				.."list[current_player;bag"..i.."contents;0,1;8,3;]"
		end
	end
	
	-- creative
	if page=="creative" and minetest.setting_getbool("creative_mode") then
		return "size[13,7.5]"
			.."list[current_player;main;5,3.5;8,4;]"
			.."list[current_player;craft;8,0;3,3;]"
			.."list[current_player;craftpreview;12,1;1,1;]"
			.."list[detached:creative;main;0.3,0.5;4,6;0]"
			.."button[0.3,6.5;1.6,1;creative_prev;<<]"
			.."button[2.7,6.5;1.6,1;creative_next;>>]"
	end

	-- default (craft/armor)
	return formspec
		.."list[detached:"..player:get_player_name().."_armor;armor_helmet;0,0;1,1;]"
		.."list[detached:"..player:get_player_name().."_armor;armor_chest;0,1;1,1;]"
		.."list[detached:"..player:get_player_name().."_armor;armor_boots;0,2;1,1;]"
		.."list[detached:"..player:get_player_name().."_armor;armor_shield;2,1;1,1;]"
		.."image[1,0.5;1,2;player.png]"
		.."list[current_player;craft;4,0;3,3;]"
		.."list[current_player;craftpreview;7,1;1,1;]"
		
end


-- on_player_receive_fields
bags.on_player_receive_fields = function(player, formname, fields)
	if fields.creative or fields.creative_prev or fields.creative_next then
		if fields.creative then
			player:set_inventory_formspec(bags.get_formspec(player,"creative"))
		end
		return
	end
	if fields.armor then
		player:set_inventory_formspec(bags.get_formspec(player,"armor"))
		return
	end
	if fields.bags then
		player:set_inventory_formspec(bags.get_formspec(player,"bags"))
		return
	end
	for i=1,4 do
		local bag = "bag"..i
		if fields[bag] then
			if bags.get_bagslots(player:get_inventory():get_stack(bag, 1))~=nil then
				player:set_inventory_formspec(bags.get_formspec(player,bag))
			end
			return
		end
	end
	player:set_inventory_formspec(bags.get_formspec(player))
end


-- on_joinplayer
bags.on_joinplayer = function(player)

	-- player inventory
	local player_inv = player:get_inventory()
	
	-- bags inventory
	local bags_inv = minetest.create_detached_inventory(player:get_player_name().."_bags",{
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			player:get_inventory():set_size(listname.."contents", bags.get_bagslots(stack))
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
		end,
		allow_put = function(inv, listname, index, stack, player)
			if bags.get_bagslots(stack) then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			if player:get_inventory():is_empty(listname.."contents")==true then
				return stack:get_size(listname)
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

	-- armor inventory
	local armor_inv = minetest.create_detached_inventory(player:get_player_name().."_armor",{
		on_put = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, stack)
			bags.set_armor_groups(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
			bags.set_armor_groups(player)
		end,
		allow_put = function(inv, listname, index, stack, player)
			if inv:is_empty(listname) and bags.get_armor_level(stack,listname) then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			return stack:get_count()
		end,
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
	})
	for _,v in ipairs({"boots","chest","helmet","shield"}) do
		local armor = "armor_"..v
		player_inv:set_size(armor, 1)
		armor_inv:set_size(armor, 1)
		armor_inv:set_stack(armor,1,player_inv:get_stack(armor,1))
	end

	-- player initial setup
	player:set_inventory_formspec(bags.get_formspec(player))
	bags.set_armor_groups(player)
end


-- get_bagslots
bags.get_bagslots = function(stack)
	if stack then
		return stack:get_definition().groups.bagslots
	end
end


-- get_armor_level
bags.get_armor_level = function(stack,armor_type)
	if stack then
		return stack:get_definition().groups[armor_type]
	end
end

-- set_armor_groups
bags.set_armor_groups = function(player)
	local level
	local armor_groups = {level=4,fleshy=4,snappy=4,choppy=4}
	player_inv = player:get_inventory()

	-- helmet
	level = bags.get_armor_level(player_inv:get_stack("armor_helmet", 1),"armor_helmet")
	if level~=nil then
		armor_groups.level = level
	end
	-- chest
	level = bags.get_armor_level(player_inv:get_stack("armor_chest", 1),"armor_chest")
	if level~=nil then
		armor_groups.fleshy = level
	end
	-- boots
	level = bags.get_armor_level(player_inv:get_stack("armor_boots", 1),"armor_boots")
	if level~=nil then
		armor_groups.snappy = level
	end
	-- shield
	level = bags.get_armor_level(player_inv:get_stack("armor_shield", 1),"armor_shield")
	if level~=nil then
		armor_groups.choppy = level
	end

	player:set_armor_groups(armor_groups)
	print(dump(armor_groups))
end

-- register armor
bags.register_armor = function(name,label,material,level)

	-- tools
	minetest.register_tool("bags:armor_helmet_"..name, {
		description = label.." Helmet",
		inventory_image = "armor_helmet_"..name..".png",
		groups = {armor_helmet=level},
		wear = 0,
	})
	minetest.register_tool("bags:armor_chest_"..name, {
		description = label.." Chestplate",
		inventory_image = "armor_chest_"..name..".png",
		groups = {armor_chest=level},
		wear = 0,
	})
	minetest.register_tool("bags:armor_boots_"..name, {
		description = label.." Boots",
		inventory_image = "armor_boots_"..name..".png",
		groups = {armor_boots=level},
		wear = 0,
	})
	minetest.register_tool("bags:armor_shield_"..name, {
		description = label.." Shield",
		inventory_image = "armor_shield_"..name..".png",
		groups = {armor_shield=level},
		wear = 0,
	})

	-- crafts
	minetest.register_craft({
		output = "bags:armor_helmet_"..name,
		recipe = {
			{material, material, material},
			{material, "", material},
			{material, "", material},
		},
	})
	minetest.register_craft({
		output = "bags:armor_chest_"..name,
		recipe = {
			{material, material, material},
			{material, material, material},
			{"", material, ""},
		},
	})
	minetest.register_craft({
		output = "bags:armor_boots_"..name,
		recipe = {
			{material, "", material},
			{material, "", material},
			{material, "", material},
		},
	})
	minetest.register_craft({
		output = "bags:armor_shield_"..name,
		recipe = {
			{material, material, material},
			{material, "", material},
			{material, material, material},
		},
	})
	
end
