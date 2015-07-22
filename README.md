-- Working Copy Client

function setup()
    
end

--[=[
local function commitMultiFile()   
    --get project name
    local projectName = string.match(readProjectTab("Main"), "^%s-%-%-%s-(.-)\n") or "My Project"
    projectName = urlencode(string.gsub(projectName, "%s", ""))
    -- concatenate multiple write commands, one for each tab
    local tabs = listProjectTabs()
    local totalURL = ""
    
    for i,tabName in ipairs(tabs) do
        local tab=readProjectTab(tabName)
        --convert tab README to .md and place in root
        
        if string.find(tabName, "^README") then
            tab=string.match(tab, "^%s-%-%-%[%[(.-)%]%]") --strip out --[[ ]]
            tabName = tabName..".md"
        else  
            tabName = "tabs/"..tabName..".lua"
        end
             
        local newLink = "working-copy://x-callback-url/write/?key="..workingCopyKey.."&repo="..projectName.."&path="..tabName.."&uti=public.txt&text="..urlencode(tab).."&x-success="       
        if i>1 then --from second link onwards, urls must be double-encoded
            newLink = urlencode(newLink)
        end
        print(i,tabName, tab)
        totalURL = totalURL..newLink
    end
       
    --add commit command
    --encode commit message
    local commitEncode = urlencode(commitMessage)
    totalURL = totalURL..urlencode("working-copy://x-callback-url/commit/?key="..workingCopyKey.."&repo="..projectName.."&limit=999&message="..commitEncode) 
        
    openURL(totalURL) 
    print(totalURL)
    print(projectName.." saved")
end

  ]=]




