-- Working Copy Client

local workingCopyKey = readGlobalData("workingCopyKey", "")
--print ("Working Copy key", workingCopyKey)

local function urlencode(str)
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])", 
        function (c)
            return string.format ("%%%02X", string.byte(c))
        end)
    str = string.gsub (str, " ", "%%20") -- %20 encoding, not + 
    return str
end

local function commitSingleFile()   
    --concatenate project tabs in Codea "paste into project" format and place in pasteboard
    local tabs = listProjectTabs()
    local tabString = ""
    for i,tabName in ipairs(tabs) do
        local tab=readProjectTab(tabName)

        tabString = tabString.."--# "..tabName.."\n"..tab.."\n\n"
        print(i,tabName)
    end
  --  tabString = urlencode(tabString) --encode if passing code in URL, using &text="..tabString
    pasteboard.copy(tabString) --avoid encoding by placing code in pasteboard
    
    --get project name
    local projectName = urlencode(string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "My Project")

    --encode commit message
    local commitEncode = urlencode(commitMessage)
    --build URL chain, starting from end
   -- local openPageURL = "working-copy://open?repo=Codea&path="..projectName..".lua&mode=content"
    local commitURL = urlencode("working-copy://x-callback-url/commit/?key="..workingCopyKey.."&repo=Codea&path="..projectName..".lua&limit=1&message="..commitEncode.."&x-success="..urlencode("codea://")) --to chain urls, must be double-encoded. .."&x-success="..openPageURL
    
    local totalURL = "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo=Codea&path="..projectName..".lua&uti=public.txt&x-success="..commitURL --&text="..tabString..
    openURL(totalURL) 
    print(totalURL)
    print(projectName.." saved")
end

local function commitMultiFile()   
    --get project name
    local projectName = string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "My Project"
    projectName = urlencode(string.gsub(projectName, "%s", ""))
    
    -- build URL, starting from the end of the chain    
    --add commit command
    local commitEncode = urlencode(commitMessage)
    local totalURL = "working-copy://x-callback-url/commit/?key="..workingCopyKey.."&repo="..projectName.."&limit=999&message="..commitEncode
  --  local totalURL = "working-copy://x-callback-url/commit/?message="..commitEncode
    print(totalURL)
    local tabs = listProjectTabs() --get project tab names
    for i=#tabs,1,-1 do --iterate through in reverse order
        local tabName = tabs[i]
        local tab=readProjectTab(tabName)
        --convert tab README to .md and place in root
        if string.find(tabName, "^README") then
            tab=string.match(tab, "^%s-%-%-%[=-%[(.-)%]=-%]") --strip out --[[ ]], --[=[, ]=]
            tabName = tabName..".md"
        else  --place in folder tabs
            tabName = "tabs/"..tabName..".lua"
        end
             
        local newLink = "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo="..projectName.."&path="..tabName.."&uti=public.txt&text="..urlencode(tab).."&x-success="    --the write command
       -- local newLink = "working-copy://x-callback-url/write/?path="..tabName.."&text="..urlencode(tab).."&x-success="    --the write command
        totalURL = newLink..urlencode(totalURL) --each link in chain has to be re-encoded
        print(i,tabName, totalURL)
    end
        
    openURL(totalURL) 

    print(projectName.." saved")
end


local function WorkingCopyClient()
    parameter.clear()
    parameter.text("commitMessage", "")
    parameter.action("Commit as single file", commitSingleFile)
    parameter.action("Commit as multiple files", commitMultiFile)
    parameter.text("workingCopyKey", workingCopyKey, function(v) saveGlobalData("workingCopyKey", v) end)
    parameter.action("Exit Working Copy Client", parameter.clear)
end

parameter.action("Working Copy client", WorkingCopyClient)