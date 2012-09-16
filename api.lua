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
				return 1
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
		end,
		on_take = function(inv, listname, index, stack, player)
			player:get_inventory():set_stack(listname, index, nil)
		end,
		allow_put = function(inv, listname, index, stack, player)
			if inv:is_empty(listname) and bags.is_armor(stack,listname) then
				return 1
			else
				return 0
			end
		end,
		allow_take = function(inv, listname, index, stack, player)
			return 1
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

	-- set formspec
	player:set_inventory_formspec(bags.get_formspec(player))
end


-- get_bagslots
bags.get_bagslots = function(stack)
	if stack then
		return stack:get_definition().groups.bagslots
	end
end

-- is_armor
bags.is_armor = function(stack,armor_type)
	if stack then
		return stack:get_definition().groups[armor_type]
	end
end
