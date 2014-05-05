--[[
 * Copyright (C) 2014 Marcus Lundblad
 *
 * Contact: Marcus Lundblad <ml@update.uu.se>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 *
--]]

---------------------------
-- Source initialization --
---------------------------

source = {
       id = "grl-svtplay-lua",
       name = "SVT Play",
       description = "A source for browsing SVT Play online TV",
       supported_keys = {"id", "thumbnail", "title", "url" },
       icon = 'http://www.svtplay.se/public/version_9da2f27cafd6d3d45bd7c68069263eac3d4d4f66/images/svt-play-2x.png',
       supported_media = 'video',
       tags = { 'tv', 'country:se' }
}

SVTPLAY_PROGRAM_URL = 'http://www.svtplay.se/program'

------------------
-- Source utils --
------------------

function grl_source_browse(media_id)
  if grl.get_options("skip") > 0 then
    grl.callback()
  else
    grl.fetch(SVTPLAY_PROGRAM_URL, "svtplay_fetch_cb")
  end
end

------------------------
-- Callback functions --
------------------------
-- return all the media found
function svtplay_fetch_cb(results)
   if not results then
      grl.callback()
   end

   for stream, title in results:gmatch('<a href="(.-)" class="playAlphabeticLetterLink">(.-)</a>') do
       media = {}
       media['type'] = 'box' 
       media.title = title

       grl.callback(media, -1)
   end
   
   grl.callback()
end