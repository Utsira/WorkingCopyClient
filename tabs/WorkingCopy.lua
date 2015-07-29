-- Working Copy Client

local workingCopyKey = readGlobalData("workingCopyKey", "")
local workingCopyPushIAP = readGlobalData("workingCopyPushIAP", false)
--local workingCopyRepoName = readLocalData("")
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

local function concatURL(url1, url2, sep)
    local sep = sep or "&x-success="
    return url1..sep..urlencode(url2) --to chain urls, must be double-encoded.
end

local function createCommitURL(repo, limit, path)
    if path then path = "&path="..path..".lua" else path = "" end
    local commitURL= "working-copy://x-callback-url/commit/?key="..workingCopyKey.."&repo="..repo..path.."&limit="..limit.."&message="..urlencode(commitMessage)
    
    if workingCopyPushIAP then --add push command
        commitURL = concatURL(commitURL, "working-copy://x-callback-url/push/?key="..workingCopyKey.."&repo="..repo)
    end
    return commitURL
end

local function commitSingleFile()   
    --concatenate project tabs in Codea "paste into project" format and place in pasteboard
    local tabs = listProjectTabs()
    local tabString = ""
    for i,tabName in ipairs(tabs) do
        tabString = tabString.."--# "..tabName.."\n"..readProjectTab(tabName).."\n\n"
        print(i,tabName)
    end
    
    --get project name
    local projectName = urlencode(string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "My Project")
    
    --build URL chain, starting from end
    local commitURL = createCommitURL("Codea", 1, projectName)   
    local writeURL = "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo=Codea&path="..projectName..".lua&uti=public.txt&text="..urlencode(tabString)
    openURL(concatURL(writeURL, commitURL)) 
    print(projectName.." saved")
end

local function commitMultiFile()   
    --get project name
    local projectName = string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "My Project"
    projectName = urlencode(string.gsub(projectName, "%s", ""))    
    -- build URL, starting from the end of the chain    
    
    local totalURL = createCommitURL(projectName, 999)
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
             
        local newLink = "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo="..projectName.."&path="..tabName.."&uti=public.txt&text="..urlencode(tab)    --the write command
       -- local newLink = "working-copy://x-callback-url/write/?path="..tabName.."&text="..urlencode(tab).."&x-success="    --the write command
        totalURL = concatURL(newLink, totalURL) --each link in chain has to be re-encoded
        print(i,tabName, totalURL)
    end
        
    openURL(totalURL) 

    print(projectName.." saved")
end

local function WorkingCopyClient()
    local function WorkingCopySettings()
        parameter.clear()
        output.clear()
        print([[
    SET UP
    ======
    1. In Working Copy settings, turn on "URL Callbacks" and copy the URL key to the clipboard. Paste the key into the workingCopyKey box. 
    2. If you have bought the push IAP in Working Copy (recommended), set workingCopyPushIAP to true. This enables to sync the local repositories on your iPad with remote hosts on GitHub, BitBucket, your computer etc.]]
        )
        parameter.text("workingCopyKey", workingCopyKey, function(v) saveGlobalData("workingCopyKey", v) end)
        parameter.boolean("workingCopyPushIAP", workingCopyPushIAP, function(v) saveGlobalData("workingCopyPushIAP", v) end)
        parameter.action("Return", WorkingCopyClient)
    end
    parameter.clear()
    parameter.text("commitMessage", "")
    parameter.action("Commit as single file", commitSingleFile)
    parameter.action("Commit as multiple files", commitMultiFile)
    parameter.action("Set up", WorkingCopySettings)
    parameter.action("Exit Working Copy Client", parameter.clear)
end

parameter.action("Working Copy client", WorkingCopyClient)