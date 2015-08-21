-- Working Copy

--[[
local workingCopyKey = readGlobalData("workingCopyKey", "")
local workingCopyPushIAP = readGlobalData("workingCopyPushIAP", false)
local workingCopyRepoName = readLocalData("workingCopyRepoName", "Codea")
local Save_project_as_single_file = readLocalData("Save_project_as_single_file", true)
  ]]
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

local function createWriteURL(repo, path, txt)
    return "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo="..repo.."&path="..path.."&uti=public.txt&text="..urlencode(txt)    --the write command
end
--Single file, to Codea repository
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
    local commitURL = createCommitURL(workingCopyRepoName, 1, projectName)   
    local writeURL = createWriteURL(workingCopyRepoName, projectName..".lua", tabString) --"working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo=Codea&path="..projectName..".lua&uti=public.txt&text="..urlencode(tabString)
    openURL(concatURL(writeURL, commitURL)) 
    print(projectName.." saved")
end

local function readProjectFile(project, name, warn)
    local path = os.getenv("HOME") .. "/Documents/"
    local file = io.open(path .. project .. ".codea/" .. name,"r")
    if file then
        local plist = file:read("*all")
        file:close()
        return plist
    elseif warn then
        print("WARNING: unable to read " .. name)
    end
end

local function readProjectPlist(project)
    return readProjectFile(project, "Info.plist", true)
end

--multi-file, to dedicated repository
local function commitMultiFile()   
    --get project name
    local projectName = string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "My Project"
    
    --get plist file with tabOrder
    local plist = readProjectPlist(projectName)
  --  print(plist)
    -- build URL, starting from the end of the chain    
     projectName = urlencode(string.gsub(projectName, "%s", ""))  
    
    local totalURL = concatURL(createWriteURL(workingCopyRepoName, "Info.plist", plist), createCommitURL(workingCopyRepoName, 999))
  --  print(totalURL)
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
             
        local newLink = createWriteURL(workingCopyRepoName, tabName, tab) --"working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo="..projectName.."&path="..tabName.."&uti=public.txt&text="..urlencode(tab)    --the write command
       
        totalURL = concatURL(newLink, totalURL) --each link in chain has to be re-encoded
      --  print(i,tabName, totalURL)
    end
        
    openURL(totalURL) 

    print(workingCopyRepoName.." saved")
end

local function WorkingCopyCommit()
    if Save_project_as_single_file then
        commitSingleFile()
    else
        commitMultiFile()
    end
end

local function WorkingCopyClient()
    local function WorkingCopySettings()
        parameter.clear()
        output.clear()
        print([[
    GLOBAL SETTINGS
    ===============
    1. In Working Copy settings, turn on "URL Callbacks" and copy the URL key to the clipboard. Paste the key into the workingCopyKey box. 
    PROJECT SETTINGS
    ================
    2. Whether to push the local repositories on your iPad to remote hosts on GitHub, BitBucket, your computer etc. Requires the push IAP in Working Copy (recommended).
    3. Whether you want to push this project as a concatena-ed single file, or as multiple files
    4. Repository name
    ]]
        )
        parameter.text("workingCopyKey", 
            readGlobalData("workingCopyKey", ""), 
            function(v) saveGlobalData("workingCopyKey", v) end)
        
        parameter.boolean("Push_to_remote_repo", 
            readLocalData("Push_to_remote_repo", false), 
            function(v) saveLocalData("Push_to_remote_repo", v) Push_to_remote_repo = v end)
        
        parameter.boolean("Save_project_as_single_file", 
            readLocalData("Save_project_as_single_file", true), 
            function(v) saveLocalData("Save_project_as_single_file", v) Save_project_as_single_file = v end)
        
        parameter.text("workingCopyRepoName", 
            readLocalData("workingCopyRepoName", "Codea"), 
            function(v) saveLocalData("workingCopyRepoName", v) workingCopyRepoName = v end)
        
        parameter.action("Set repo name to project name", function()
            local projectName = string.match(readProjectTab("Main"), "^%s*%-%-%s*(.-)\n") or "MyProject"
            projectName = string.gsub(projectName, "%s", "")
            workingCopyRepoName = projectName
            saveLocalData("workingCopyRepoName", projectName)
            pasteboard.copy(projectName)
            Save_project_as_single_file=false
            saveLocalData("Save_project_as_single_file", false)
            print ("Repository name is now in clipboard")
        end)
        parameter.action("Return", WorkingCopyClient)
    end
    parameter.clear()
    parameter.text("commitMessage", "")
    parameter.action("Commit", WorkingCopyCommit)
    parameter.action("Set up", WorkingCopySettings)
    parameter.action("Exit Working Copy Client", parameter.clear)
end

parameter.action("Working Copy client", WorkingCopyClient)