sfinv.register_page("bags:bags", {
	title = "Bags",
	get = function(self, player, context)
		local bags_inv = ""
		if context.bags_page == nil or context.bags_page == "bags" then
			bags_inv = "button[0,2;2,0.5;bag1;Bag 1]"
					 .."button[2,2;2,0.5;bag2;Bag 2]"
					 .."button[4,2;2,0.5;bag3;Bag 3]"
					 .."button[6,2;2,0.5;bag4;Bag 4]"
					 .."list[detached:"..player:get_player_name().."_bags;bag1;0.5,1;1,1;]"
					 .."list[detached:"..player:get_player_name().."_bags;bag2;2.5,1;1,1;]"
					 .."list[detached:"..player:get_player_name().."_bags;bag3;4.5,1;1,1;]"
					 .."list[detached:"..player:get_player_name().."_bags;bag4;6.5,1;1,1;]"
		else
			for i=1,4 do
				if context.bags_page=="bag"..i then
					local image = player:get_inventory():get_stack("bag"..i, 1):get_definition().inventory_image
					bags_inv = "button[2,0;2,0.5;bags_return;Return]"
						.."image[7,0;1,1;"..image.."]"
						.."list[current_player;bag"..i.."contents;0,1;8,3;]"
						.."listring[current_name;bag"..i.."contents]"
						.."listring[current_player;main]"
				end
			end
		end

		local formspec = sfinv.make_formspec(player, context, bags_inv, true)
		return formspec
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.bags_return then
			context.bags_page = "bags"
			sfinv.set_player_inventory_formspec(player)
			return true
		end

		for i=1,4 do
			local page = "bag"..i
			if fields[page] then
				if player:get_inventory():get_stack(page, 1):get_definition().groups.bagslots==nil then
					context.bags_page = "bags"
				else
					context.bags_page = page
				end
				sfinv.set_player_inventory_formspec(player)
				return true
			end
		end
		return false
	end
})
