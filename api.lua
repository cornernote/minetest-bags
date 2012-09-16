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
		.."button[4,0;2,0.5;main;Craft]"
		.."button[6,0;2,0.5;bags;Bags]"
		.."list[current_player;main;0,4.5;8,4;]"

	-- bags inventory page
	if page=="bags" then
		return formspec
			--.."label[0,0;Bags]"
			.."button[0,3;2,0.5;bag1;Bag 1]"
			.."list[detached:"..player:get_player_name().."_bags;bag1;0.5,2;1,1;]"
			
			.."button[2,3;2,0.5;bag2;Bag 2]"
			.."list[detached:"..player:get_player_name().."_bags;bag2;2.5,2;1,1;]"

			.."button[4,3;2,0.5;bag3;Bag 3]"
			.."list[detached:"..player:get_player_name().."_bags;bag3;4.5,2;1,1;]"

			.."button[6,3;2,0.5;bag4;Bag 4]"
			.."list[detached:"..player:get_player_name().."_bags;bag4;6.5,2;1,1;]"
		end

	-- bag invenory page
	for i=1,4 do
		if page=="bag"..i then
			local image = player:get_inventory():get_stack("bag"..i, 1):get_definition().inventory_image
			return formspec
				.."image[0,0;1,1;"..image.."]"
				.."list[current_player;bag"..i.."contents;0,1;8,3;]"
		end
	end
	
	-- default invenory page
	return formspec
		--.."label[0,0;Player Inventory]"
		.."list[current_player;craft;3,1;3,3;]"
		.."list[current_player;craftpreview;7,2;1,1;]"
		.."image[1,1.5;1,2;player.png]"
		
end


-- on_player_receive_fields
bags.on_player_receive_fields = function(player, formname, fields)
	if minetest.setting_getbool("creative_mode") then return end
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
	if minetest.setting_getbool("creative_mode") then return end
	local pinv = player:get_inventory()
	local inv = minetest.create_detached_inventory(player:get_player_name().."_bags",{
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
		inv:set_size(bag, 1)
		inv:set_stack(bag,1,pinv:get_stack(bag,1))
		pinv:set_size(bag, 1)
	end
	player:set_inventory_formspec(bags.get_formspec(player))
end


-- get_bagslots
bags.get_bagslots = function(stack)
	if stack then
		return stack:get_definition().groups.bagslots
	end
end