----------------------------------
Bags for Minetest
----------------------------------


Copyright (c) 2012 cornernote, Brett O'Donnell <cornernote@gmail.com>
Textures: Copyright (c) 2012 tonyka

Source Code: https://github.com/cornernote/minetest-bags
Home Page: https://sites.google.com/site/cornernote/minetest/bags

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


----------------------------------
Description
----------------------------------

Allows players to craft and attach bags to their inventory to increase player item storage capacity.


----------------------------------
Crafts
----------------------------------

8-slot bag:
-S-  <- bag:small
WWW     S = default:stick
WWW     W = default:wood

16-slot bag:
-S-  <- bag:medium
BBB     S = default:stick
BBB     B = bags:small

24-slot bag:
-S-  <- bag:large
BBB     S = default:stick
BBB     B = bags:medium


----------------------------------
Modders Guide
----------------------------------

To turn your craftitem into a bag simply add bagslots=X to the groups in the node definition.

EG:
minetest.register_node("your_mod:your_item", {
	description = "Your Item",
	groups = {bagslots=16},
})

