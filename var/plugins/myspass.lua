--[[
	Myspass-Plugin

	The MIT License (MIT)

	Copyright (c) 2014 Ezak from www.coolstream.to

	Icons by Tischi thx ;)

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
]]

local posix = require "posix";

function init()
	n = neutrino();
	serienCount 		= 0;
	seasonCount         = 0;
	episodesCount       = 0;
	serieAction         = 0;
	seasonAction        = 0;
	episodeAction       = 0;
	seriePage           = 0;
	seriesTable      	= {};
	seasonsTable        = {};
	infoAction          = 0;
	baseUrl				= "http://www.myspass.de"
	tmpPath 			= "/tmp/myspass"
	os.execute("rm -fr " .. tmpPath)
	os.execute("sync")
	os.execute("mkdir -p " .. tmpPath)
	user_agent 			= "\"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20100101 Firefox/31.0\""
	wget_cmd 			= "wget -q -U " .. user_agent .. " -O "
	wget_script_file = "/tmp/myspass_wget.sh";
	wget_busy_file = "/tmp/myspass_wget.busy";
	downl_ready_file = "/tmp/myspass_download_ready.lua";
	myspass_png 		= decodeImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6QUFDMzEwNjY3NEU0MTFFNEFCRjM4OEYxMTFCRDBDMzYiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6QUFDMzEwNjc3NEU0MTFFNEFCRjM4OEYxMTFCRDBDMzYiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDpBQUMzMTA2NDc0RTQxMUU0QUJGMzg4RjExMUJEMEMzNiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDpBQUMzMTA2NTc0RTQxMUU0QUJGMzg4RjExMUJEMEMzNiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Po9xrpMAAAWPSURBVHjanFVZiFxFFD1Vb+3p6e5JJovjjJOoqIkiMW4x4obiAsmHBhGEqB8qUREF8yGKCCIioigqiFEEEQR3Ub/il1tIQDFixCRGYhJn1DhLerrnLf3qVZWnukeNYUC0mvse73W9c+8999xb4oZXt+PPJQSg+RNBiFQZzOYKHYFLLfxrSynOVEIMdTRkZjCZKb07N+LjHPJ9pUoNzwOMBlQGh0K0LqaPeZY2lmbWVyL/+XocLRdhAO35dOYhtUBC536hLxK5ur3MVKIKPAhjn5sPyxf2GHBrmYl5b3Etvq5arcCPIxg/QCEJDolZIxCWBqJglJ0SOimqKsieLdP8bhTlhYCdpP3tQEvx14MxBqHv7VgyUF0z2OhHFIeQYQjl+8gI3qaFWkCUzJAONPnqBApZEKEMklPEkeZ+m2MFhPyly3fXQdBjq0PwisTWkQX9a4YHaxioxnTQiz5n9A7cs65IAqrk/kAj9zUiUheQOiEkrDE1afTXpqNP5Ius6yBgfcgKYmvvWtKoXjU0UMVIPcYiOvDIfe4FaMEVUMCxkkvuZXQRQSPBjHkPLB3QuS0Vi1wsFWVzC7O42RVezpLPttJhEAaPDRJ8YX+M46oRTugPsagSoBr6jFKyWIB3tEm+I3UuCC8KIeIYqFSAah9kFN4kPO88BAFkYVgSITdW++KBmJSE5FzyD8PUDanRtld4dzdHmeU79wP3IKAY+Q0/BqIIlrSKPN2EdhOSkjwLUq73XRSMSHNzyo+mmXaTtCQMIKcVxFK00hl6pruqc2Uh/z4dMVunrGhkGKZRvwadzmWysPJc6/nnGIIrAmfku2V9TBuJaaLMEGWWDjIC5bQOuVZzztRRzgxpRFtj3fFVPHzZMFkJh63GObIU3hlKyNGCUXR1TnORTxF4mtaktelglvd0zpGzjumZyyx3cpkxWFzz8OHlS7A04rNkNlIsc31QUxRqm/Jzu0Pt+oGU6h7XDsRF7qianaMsdT3m3tF+JrpNgXOXAJ+u7HfI2MNnJ03qKvTT0oyVnsmPEyLuDz1snymxXFJBUW82KYI6MDciyECXsjGqcQ+BNYM6jZgPnQRsHPx76uxs8VKQbGuaflbYnQX07r3tYvXja+uY4EdvTBjsJ0CbfDtaug7m7m4tJNbtiwU2LACurP9z1MzQPj3Mj5OWtULs8Ttab/dKfD4+k6/+YCzB5hUDWNsADhHtQCEwWfZU5PqgQaGMMrNTot7zfOs19m8xPgGZpl+yUbb5Sorfi9K8XdflPU99fwTXL6tjGWfGaCS6YP9ludnw0hgvPx8iv/JtY+Q+mYmQKgi+KIty229TCe7dOYX/u55pA999tQ+YnEykFC960kAqSkaxI1t5ublqFT74fgr37Wr9Z/B3C+CJz38FfthHZrwHrCdmaVTSmxN/HWdCqc0wnadsVuDsFYvwyvkLcNa/0ERcPE2IJ3eMYXrvQfhR3+u6r7KR02FOquvuRPeAcJNwcAQ4+ezbcPqal+GGFFldeepi3Dhaw8ULgeWcZ86fk/kBEr5jyuKtHyfw7aFmtxO98d1b7E/f3GEP/9TTOJt3Xi0EZ15ykb3l0Y/K5asGkMyyGSi7WgiPE7ZB+Wil0Uo7sN0hxXNi4iCCrS9syj9566VjsY514NViEdRynksLGvXsgg33J6uvvrUYPnUpYgqes797eChmmzYhJg+ljb1fvFPd8c4jdnx8fxaLsFlwh2Ex53EggkD4Q0NDcWnkgMxbwj/Sapn+yqri+NOuUItGV5lKfYSp+zJPDvvT47uC3/Z95h+Z3lbW+gJTHYh43DYnJn7PkqTjHJj5MpCVSujXao04DIM+IWVd6LIis5YQnbTCA6zq9nQbPIxSW6kbG0QdHpUtrVWaJEnWaqXFn+Bu/SHAAAxdsz7t/TiOAAAAAElFTkSuQmCC");
	create_downloader();
end

-- ####################################################################
-- function from http://lua-users.org/wiki/BaseSixtyFour

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- decode
function dec(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
	if (x == '=') then return '' end
	local r,f='',(b:find(x)-1)
	for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
	return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
	if (#x ~= 8) then return '' end
	local c=0
	for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
	return string.char(c)
	end))
end
-- ####################################################################

function decodeImage(b64Image)
	local imgTyp = b64Image:match("data:image/(.-);base64,")
	local repData = "data:image/" .. imgTyp .. ";base64,"
	local b64Data = string.gsub(b64Image, repData, "");

	local retImg = tmpPath .. "/" .. "icon" .. "." .. imgTyp;

	local f = io.open(retImg, "w+")
	f:write(dec(b64Data))
	f:close()

	return retImg
end
-- ####################################################################

--Stream Download-Script erstellen
function create_downloader()

	local ds = io.open(wget_script_file, "w");
	if ds then
		ds:write(
[[
#!/bin/sh

wget_busy_file=]] .. wget_busy_file .. "\n" .. [[
movie_file="$2"
stream_url="$1"

netzkino_wget() {
	touch $wget_busy_file
	wget -c -O "${movie_file}" "${stream_url}"
	rm $wget_busy_file
	/tmp/myspass_download_ready.lua
}

if [ ! -e $wget_busy_file ]; then
	netzkino_wget &
fi
]]
		)
		ds:close()

		os.execute(string.format('chmod 755 %s', wget_script_file))
	else
		print(wget_script_file .. " konnte nicht angelegt werden")
	end
end

function readFile(_File)
	local fp, s
	fp = io.open(_File, "r")
	if fp == nil then 
		error("Error opening file '" .. _File .. "'.");
	end
		s = fp:read("*a");
		fp:close();
		return s;
end


function getSeries()
	seriesTable = {};
	local tmpFile = tmpPath .. "/myspass_series.txt"
	local h = hintbox.new{caption="Myspass.de", text="Serien werden geladen ...", icon=myspass_png};
	h:paint();
	os.execute(wget_cmd .. tmpFile .. " '" .. baseUrl .. "/ganze-folgen/'");
	local seriesSourceCode = readFile(tmpFile);
-- Parse Series from seriesSourceCode
	i = 1;
	for serie in string.gmatch(seriesSourceCode, "<div class=\"myspassTeaser _seasonId seasonlistItem \"(.-)</div>") do
		seriesTable[i] = 
			{
				id = i;
				title = serie:match("alt=\"(.-)\"");
				link = serie:match("<a href=\"(.-)\"");
			};;
			i = i + 1;
	end
	serienCount = i-1;
	h:hide();
	getSeriesMenu(seriesTable,1);
end

function getSeriesMenu(_seriesTable, _offsetPage)
	selectedSerie = 0;
	serieAction = 0;
	seriePage = _offsetPage;
	maxPage = _offsetPage+9;
	local numberText = "";
	menuSeries = menu.new{name="Myspass Serien", icon=myspass_png};
	if maxPage-1 > serienCount then
		numberText = "Serie " .. _offsetPage .. " bis 70 von " .. serienCount;		
	else
		numberText = "Serie " .. _offsetPage .. " bis " .. maxPage-1 .. " von " .. serienCount;
	end
	menuSeries:addItem{type="subhead", name=numberText};
	
	if maxPage < serienCount then	
		menuSeries:addItem{type = "forwarder", name = "Nächste Seite", action = "nextSerienPage", icon = "blau", directkey = RC["blue"]};
		menuSeries:addKey{directkey=RC["right"], action="nextSerienPage"};
	end
	if _offsetPage > 1 then
		menuSeries:addItem{type = "forwarder", name = "Vorherige Seite", action = "previousSerienPage", icon = "gelb", directkey = RC["yellow"]};
		menuSeries:addKey{directkey=RC["left"], action="previousSerienPage"};
	end
	menuSeries:addItem{type="separator"};

	i = _offsetPage;
	j = 1;
	while i<maxPage and i<serienCount+1 do
			serieName = _seriesTable[i].title;
			menuSeries:addItem{type="forwarder", name=serieName, action="setSerie", id=i, icon=j, directkey=RC[tostring(j)]};
			i = i+1;
			j = j+1;
	end

	menuSeries:exec();

	if selectedSerie == 0 then
		return MENU_RETURN["EXIT_ALL"];
	elseif selectedSerie == -2 then
		if _offsetPage-9 > 0 then
			getSeriesMenu(_seriesTable,_offsetPage-9);
		else
			getSeriesMenu(_seriesTable,1);
		end
	elseif selectedSerie == -1 then
		getSeriesMenu(_seriesTable,_offsetPage+9);
	else
		getSeasons(_seriesTable,selectedSerie);
	end

end

function previousSerienPage()
	selectedSerie = -2
	return MENU_RETURN["EXIT_ALL"];
end

function nextSerienPage()
	selectedSerie = -1
	return MENU_RETURN["EXIT_ALL"];
end

function setSerie(_serieID)
	selectedSerie = _serieID;
	return MENU_RETURN["EXIT_ALL"];
end

function getSeasons(_seriesTable,_selectedSerie)
	seasonsTable = {};
	local tmpFile = tmpPath .. "/myspass_seasons.txt"
	local link = _seriesTable[tonumber(_selectedSerie)].link;
	local name = _seriesTable[tonumber(_selectedSerie)].title;
	local actionUrl = "/frontend/php/ajax.php?ajax=true&query=";
	local h = hintbox.new{caption="Myspass.de", text="Staffeln werden geladen ...", icon=myspass_png};
	h:paint();
	os.execute(wget_cmd .. tmpFile .. " '" .. baseUrl .. link .. "'");
	local seasonsSourceCode = readFile(tmpFile);
-- parse seasons from seasons SourceCode
	i = 1;
	for season in string.gmatch(seasonsSourceCode, "<li(.-)</li>") do
    --only full episodes
    category = season:match("data%-category=\"(.-)\"");
    query = season:match("data%-query=\"(.-)\"");
    seasonTitle = season:match(">(.*)");
    if(category == "full_episode" and query ~= nil) then
      seasonsTable[i] = 
        {
          id = i;
          title = trim(seasonTitle);
          link = baseUrl .. actionUrl .. string.gsub(query,"&amp;","&") .. "&sortBy=episode_desc";
        };
        i = i + 1; 
    end
  end
	seasonCount = i-1;
	h:hide();
	getSeasonsMenu(name,seasonsTable,1);
end

function getSeasonsMenu(_title,_seasonTable,_offsetPage)
	selectedSeason = 0;
	seasonAction = 0;
	local headerTitle = "Myspass.de " .. _title;
	maxPage = _offsetPage+9;

	menuSeasons = menu.new{name=headerTitle,icon=myspass_png};
	local numberText = "Staffel Auswahl";
	if seasonCount == 0 then
		menuSeasons:addItem{type="subhead", name="Keine Staffel gefunden"};
	else
		menuSeasons:addItem{type="subhead", name=numberText};
	end
	
	if _offsetPage > 1 then
		menuSeasons:addItem{type = "forwarder", name = "Vorherige Seite", action = "previousSeasonPage", icon = "gelb", directkey = RC["yellow"]}
		menuSeasons:addKey{directkey=RC["left"], action="previousSeasonPage"};
	end
	if maxPage < seasonCount then	
		menuSeasons:addItem{type = "forwarder", name = "Nächste Seite", action = "nextSeasonPage", icon = "blau", directkey = RC["blue"]}
		menuSeasons:addKey{directkey=RC["right"], action="nextSeasonPage"};	
	end
	menuSeasons:addItem{type="separator"};

	i = _offsetPage;
	j = 1;
	while i<maxPage and i<seasonCount+1 do
			seasonName = trim(_seasonTable[i].title);
			menuSeasons:addItem{type="forwarder", name=seasonName, action="setSeason", id=i, icon=j, directkey=RC[tostring(j)]};
			i = i+1;
			j = j+1;
	end

	menuSeasons:exec();

	if selectedSeason == 0 then
		getSeriesMenu(seriesTable,seriePage);
	elseif selectedSeason == -2 then
		if _offsetPage-9 > 0 then
			getSeasonsMenu(_title,_seasonTable,_offsetPage-9);
		else
			getSeasonsMenu(_title,_seasonTable,1);
		end
	elseif selectedSeason == -1 then
		getSeasonsMenu(_title,_seasonTable,_offsetPage+9);
	else
		getEpisodes(_title,trim(_seasonTable[tonumber(selectedSeason)].title),_seasonTable,selectedSeason);
	end
end

function previousSeasonPage()
	selectedSeason = -2
	return MENU_RETURN["EXIT_ALL"];
end

function nextSeasonPage()
	selectedSeason = -1
	return MENU_RETURN["EXIT_ALL"];
end

function setSeason(_serieID)
	selectedSeason = _serieID;
	return MENU_RETURN["EXIT_ALL"];
end

function getEpisodes(_seriesName,_seasonName,_seasonTable,_selectedSeason)
	local episodesTable = {};
	local tmpFile = tmpPath .. "/myspass_episodes.txt"
	local link = _seasonTable[tonumber(_selectedSeason)].link;
	local actionUrl = "/myspass/includes/apps/video/getvideometadataxml.php?id="
	local i = 1; 
	local h = hintbox.new{caption="Myspass.de", text="Episoden werden geladen ...", icon=myspass_png};
	h:paint();
  os.execute(wget_cmd .. tmpFile .. " '" .. link .. "'");
  local episodesSourceCode = readFile(tmpFile); 
  for episode in string.gmatch(episodesSourceCode, "<div class=\"myspassTeaser _seasonId(.-)</a>") do
    episodesTable[i] = 
			{
				id = i;
				title = episode:match("title=\"(.-)\"");
				link = baseUrl .. actionUrl .. episode:match("/(%d+)/");
			};
			i = i + 1; 
	end
	episodesCount = i - 1;
	h:hide();
	getEpisodesMenu(_seriesName,_seasonName,episodesTable,1);
end

function getEpisodesMenu(_seriesName,_seasonName,_episodesTable,_offsetPage)
	selectedEpisode = 0;
	episodeAction = 0;
	local headerTitle = _seriesName .. " " .. _seasonName;
	maxPage = _offsetPage+9;

	menuEpisodes = menu.new{name=headerTitle,icon=myspass_png};
	local numberText = "Episoden Auswahl";
	if episodesCount == 0 then
		menuEpisodes:addItem{type="subhead", name="Keine Folgen gefunden"};
	else
		menuEpisodes:addItem{type="subhead", name=numberText};
	end
	
	if _offsetPage > 1 then
		menuEpisodes:addItem{type = "forwarder", name = "Vorherige Seite", action = "previousEpisodesPage", icon = "gelb", directkey = RC["yellow"]}
		menuEpisodes:addKey{directkey=RC["left"], action="previousEpisodesPage"};	
	end
	if maxPage <= episodesCount then	
		menuEpisodes:addItem{type = "forwarder", name = "Nächste Seite", action = "nextEpisodesPage", icon = "blau", directkey = RC["blue"]}
		menuEpisodes:addKey{directkey=RC["right"], action="nextEpisodesPage"};	
	end
	menuEpisodes:addItem{type="separator"};

	i = _offsetPage;
	j = 1;
	while i<maxPage and i<episodesCount+1 do
			episodeName = tostring(i) .. ". " .. trim(_episodesTable[i].title);
			menuEpisodes:addItem{type="forwarder", name=episodeName, action="setEpisode", id=i, icon=j, directkey=RC[tostring(j)]};
			i = i+1;
			j = j+1;
	end

	menuEpisodes:exec();

	if selectedEpisode == 0 then
		getSeasons(seriesTable,selectedSerie);
	elseif selectedEpisode == -2 then
		if _offsetPage-9 > 0 then
			getEpisodesMenu(_seriesName,_seasonName,_episodesTable,_offsetPage-9);
		else
			getEpisodesMenu(_seriesName,_seasonName,_episodesTable,1);
		end
	elseif selectedEpisode == -1 then
		getEpisodesMenu(_seriesName,_seasonName,_episodesTable,_offsetPage+9);
	else
		getEpisodeInfo(_seriesName,_seasonName,_episodesTable,selectedEpisode);
	end	
end

function previousEpisodesPage()
	selectedEpisode = -2
	return MENU_RETURN["EXIT_ALL"];
end

function nextEpisodesPage()
	selectedEpisode = -1
	return MENU_RETURN["EXIT_ALL"];
end

function getEpisodeInfo(_seriesName,_seasonName,_episodesTable,_selectedEpisode)
	local infoTable = {};
	local tmpFile = tmpPath .. "/myspass_info.txt"
	local link = _episodesTable[tonumber(_selectedEpisode)].link;
	local h = hintbox.new{caption="Myspass.de", text="Infos werden geladen ...", icon=myspass_png};
	h:paint();
	os.execute(wget_cmd .. tmpFile .. " '" .. link .. "'");
	local infos = readFile(tmpFile);
	infoTable.SerieName = infos:match("<format><!%[CDATA%[(.-)%]%]></format>");
	infoTable.seasonNumber = infos:match("<season><!%[CDATA%[(.-)%]%]></season>");
	infoTable.episodeNumber = infos:match("<episode><!%[CDATA%[(.-)%]%]></episode>");
	infoTable.episodeTitle = infos:match("<title><!%[CDATA%[(.-)%]%]></title>");
	infoTable.description = infos:match("<description><!%[CDATA%[(.-)%]%]></description>");
	infoTable.duration = infos:match("<duration><!%[CDATA%[(.-)%]%]></duration>");
	infoTable.image = infos:match("<imagePreview><!%[CDATA%[(.-)%]%]></imagePreview>");
	infoTable.streamUrl = infos:match("<url_flv><!%[CDATA%[(.-)%]%]></url_flv>");
	infoTable.broadcastDate = infos:match("<broadcast_date><!%[CDATA%[(.-)%]%]></broadcast_date>");
	h:hide();
	showEpisodeInfo(_seriesName,_seasonName,infoTable);
end

function showEpisodeInfo(_seriesName,_seasonName,_infoTable)

	local spacer = 8;
	local x  = 150;
	local y  = 70;
	local dx = 1000;
	local dy = 600;
	local ct1_x = 300;
	infoAction = 0;

	episodeInfo = "Staffel: " .. _infoTable.seasonNumber .. "\n" .. "Episode: " .. _infoTable.episodeNumber .. "\n";
	episodeInfo = episodeInfo .. "Titel: " .. _infoTable.episodeTitle  .. "\n" .. "Dauer: " .. _infoTable.duration .. "\n";
	episodeInfo = episodeInfo .. "Erstausstrahlung: " .. _infoTable.broadcastDate;
	
	local wget_busy = io.open(wget_busy_file, "r")
	if wget_busy then
		wget_busy:close()
		w = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="Myspass.de", icon=myspass_png, btnRed="Film abspielen"};
	else
		w = cwindow.new{x=x, y=y, dx=dx, dy=dy, title="Myspass.de", icon=myspass_png, btnRed="Film abspielen", btnGreen="Download"};
	end

	local tmp_h = w:headerHeight() + w:footerHeight();
	ct1 = ctext.new{parent=w, x=ct1_x, y=20, dx=dx-ct1_x-2, dy=dy-tmp_h-40, text=episodeInfo, mode = "ALIGN_TOP ",font_text=FONT['MENU']};

	fontHeight = n:FontHeight(FONT['MENU']);
	y = y+28+fontHeight*4;
	ct2 = ctext.new{parent=w, x=20, y=y, dx=dx-20, dy=dy-tmp_h-40, text=_infoTable.description, mode = "ALIGN_TOP | ALIGN_SCROLL | DECODE_HTML"};

	if _infoTable.image ~= nil then
		getPicture(_infoTable.image);
	end

		local pic_x =  20
		local pic_y =  35
		local pic_w = 250
		local pic_h = 300
		local image = tmpPath .. "/myspass_image.png";
		local tmp_w;
		cpicture.new{parent=w, x=pic_x, y=pic_y, dx=pic_w, dy=pic_h, image=image}

	w:paint();
	ret = getInput(index);
	w:hide{no_restore=true};

	if infoAction == 1 then
		playStream(_infoTable);
		collectgarbage();
		getEpisodes(_seriesName,_seasonName,seasonsTable,selectedSeason,0);
	elseif infoAction == 2 then
		downloadStream(_infoTable);
		collectgarbage();
	else
		collectgarbage();
		getEpisodes(_seriesName,_seasonName,seasonsTable,selectedSeason,0);
	end

end

function getPicture(_pictureUrl)
	local tmpFile = tmpPath .. "/myspass_image.png"
	os.execute(wget_cmd .. tmpFile .. " '" .. _pictureUrl .. "'");	
end

function getInput(_id)
	repeat
		msg, data = n:GetInput(500)
		-- Taste Rot startet Stream
		if (msg == RC['ok']) or (msg == RC['red']) then
			infoAction = 1;
			msg = RC['home'];
		-- Taste Grün startet Download
		elseif (msg == RC['green']) then
			infoAction = 2;
			msg = RC['home'];
		elseif (msg == RC['up'] or msg == RC['page_up']) then
			ct2:scroll{dir="up"};
		elseif (msg == RC['down'] or msg == RC['page_down']) then
			ct2:scroll{dir="down"};
		end
	-- Taste Exit oder Menü beendet das Fenster
	until msg == RC['home'] or msg == RC['setup'];
end

function playStream(_infoTable)
	local title = _infoTable.episodeTitle;
	local url = _infoTable.streamUrl;
	local info1 = _infoTable.SerieName;
	local info2 = "Staffel " .. _infoTable.seasonNumber .. " Episode " .. _infoTable.episodeNumber;
	n:PlayFile(title,url,info1,info2);
end

function downloadStream(_infoTable)
	createDownlReadyFile();
	local downloadPath = "/media/sda1/movies";
	local streamUrl = _infoTable.streamUrl;
	local fileName = _infoTable.SerieName .. "_S" .. _infoTable.seasonNumber .. "_E" .. _infoTable.episodeNumber .. "_" .. _infoTable.episodeTitle .. ".mp4";

	local neutrinoConf = io.open("/var/tuxbox/config/neutrino.conf", "r")	
	if neutrinoConf then
		for l in neutrinoConf:lines() do
			local key, val = l:match("^([^=#]+)=([^\n]*)")
			if (key) then
				if key == "network_nfs_recordingdir" then
					downloadPath = val;
				end
			end
		end
		neutrinoConf:close();
	end
	fileName = downloadPath .. "/" .. fileName;
	local h = hintbox.new{caption="Myspass.de", text="Download nach " .. fileName .. " gestartet" , icon=myspass_png};
	h:paint();
	local i = 0;
	repeat
		i = i + 1;
		msg, data = n:GetInput(500)
	until msg == RC.ok or msg == RC.home or i == 12
	h:hide()

	print(wget_script_file .. " " .. streamUrl .. " " .. fileName);
	os.execute(wget_script_file .. " '" .. streamUrl .. "' '" .. fileName .. "'");
end

--File erstellen welches eine Benachrichtigung ausgibt, wenn der Download abgeschlossen wurde.
function createDownlReadyFile()

	local ds = io.open(downl_ready_file, "w");
	if ds then
		ds:write(
[[
#!/bin/luaclient
n = neutrino()
h = hintbox.new{caption="Myspass", text="Download beendet"}
h:paint()
repeat
	msg, data = n:GetInput(500)
until msg == RC.ok or msg == RC.home
h:hide()
]]
		)
		ds:close()
	else
		print(downl_ready_file .. " konnte nicht angelegt werden")
	end
	os.execute(string.format('chmod 755 %s', downl_ready_file))
end

function setEpisode(_episodeID)
	selectedEpisode = _episodeID;
	return MENU_RETURN["EXIT_ALL"];
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function clear()
	n = nil;
	os.execute("rm -rf " .. tmpPath);
end

--=====================
-- Main
--=====================
init();
createDownlReadyFile();
getSeries();
clear();
posix.sync()
collectgarbage();
