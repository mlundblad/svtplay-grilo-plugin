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

SVTPLAY_BASE_URL = 'http://www.svtplay.se'
SVTPLAY_PROGRAM_URL = SVTPLAY_BASE_URL .. '/program'

------------------
-- Source utils --
------------------

function grl_source_browse(media_id)
  if grl.get_options("skip") > 0 then
    grl.callback()
  else
    if not media_id then
       grl.fetch(SVTPLAY_PROGRAM_URL, "svtplay_fetch_programs_cb")
    else
       grl.debug("fetching id: " .. media_id)
       grl.fetch(SVTPLAY_BASE_URL .. media_id, "svtplay_fetch_videos_cb")
    end
  end
end

------------------------
-- Callback functions --
------------------------
-- return all the media found
function svtplay_fetch_programs_cb(results)
   if not results then
      grl.callback()
   end

   for dummy, stream, title, dummy2 in results:gmatch('<li class="playListItem playJsAlphabeticTitle "(.-)<a href="(.-)" class="playAlphabeticLetterLink">(.-)</a>(.-)</li>') do
       media = {}
       media['type'] = 'box' 
       media.title = grl.unescape(title)
       media.id = stream

       grl.callback(media, -1)
   end
   
   grl.callback()
end

function svtplay_fetch_videos_cb(results)
   if not results then
     grl.callback()
   end

   for body in results:gmatch('<article(.-)</article>') do
       grl.callback(parse_article(body), -1)
   end

   grl.callback()
end

function parse_article(body)
  local thumbnail = body:match('<img class="playGridThumbnail" alt="" src="(.-)"/>')
  local title = body:match('<h1 class="playH5 playGridHeadline">(.-)</h1>')
  local videoId = body:match('<a href="/video/(.-)/')
  local clipId = body:match('<a href="/klipp/(.-)/')

  grl.debug(body)

  local media = {}
  media.thumbnail = thumbnail
  media.type = 'video'
  media.title = trim(title)
  if videoId then
     media.external_url = SVTPLAY_BASE_URL .. '/video/' .. videoId .. '?type=embed'
  else
     media.external_url = SVTPLAY_BASE_URL .. '/klipp/' .. clipId .. '?type=embed'
  end

  return media
end

function trim(s)
  return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end