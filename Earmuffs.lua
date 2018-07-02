-- create a frame to listen to game events
--local mainFrame, mainFrameEvents = CreateFrame("FRAME"), {};

-- Create the Ace3 addon
Earmuffs = LibStub("AceAddon-3.0"):NewAddon("Earmuffs", "AceConsole-3.0", "AceEvent-3.0")
local addon	= LibStub("AceAddon-3.0"):GetAddon("Earmuffs")

local wipe = wipe

-- Options table
Earmuffs.slash = {
    name = "Earmuffs",
    handler = Earmuffs,
    type = 'group',
    args = {
        dump = {
            type = 'execute',
            name = 'DumpDB',
            desc = 'dump the NPC list',
            func = 'dumpDB',
        },
        reload = {
            type = 'execute',
            name = 'Reload',
            desc = 'reload the NPC list from defaults',
            func = 'reloadDB',
        },
    },
}

-- Options table
Earmuffs.options = {
  name = "Earmuffs",
  handler = Earmuffs,
  type = 'group',
  args = {
    general = {
      name = "Blocking Options",
      type = "group",
      args = {
        blockSayNPC = {
          order = 1,
          type = 'toggle',
          name = 'Block spammy NPCs',
          desc = 'blocks NPC talking',
          get = 'getOption',
          set = 'setOption',
        },
        blockYellsNPC = {
          order = 2,
          type = 'toggle',
          name = 'Block ALL NPC yells',
          desc = 'blocks NPC yells',
          get = 'getOption',
          set = 'setOption',
        },
        blockYellsPlayer = {
          order = 3,
          type = 'toggle',
          name = 'Block ALL player yells',
          desc = 'blocks player yells',
          get = 'getOption',
          set = 'setOption',
        },
				divider1 = {
          order	= 4,
          type	= "header",
          name	= "Misc",
        },
        addItem = {
          order	= 5,
          type	= "execute",
          func = "toggleNPCList",
          name	= "Toggle NPC List",
        },
      },
    },
  },
}

-- Register the options table
local AceConfig = LibStub("AceConfig-3.0")
AceConfig:RegisterOptionsTable("Earmuffs", Earmuffs.slash, {"earmuffs"})
AceConfig:RegisterOptionsTable("EarmuffsOptions", Earmuffs.options, nil)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
AceConfigDialog:AddToBlizOptions("EarmuffsOptions", "Earmuffs")

-- Create NPC list frame
local npcListFrame = CreateFrame("FRAME", "npcList", InsetFrameTemplate)
npcListFrame:SetPoint("CENTER")
npcListFrame:SetFrameStrata("DIALOG")
npcListFrame:SetSize(640, 480)
npcListFrame:SetBackdrop({ 
  bgFile = "Interface\\FrameGeneral\\UI-Background-Rock", 
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
  title = true
})
npcListFrame:SetMovable(true)
npcListFrame:EnableMouse(true)
npcListFrame:RegisterForDrag("LeftButton")
npcListFrame:SetScript("OnDragStart", npcListFrame.StartMoving)
npcListFrame:SetScript("OnDragStop", npcListFrame.StopMovingOrSizing)
npcListFrame:SetClampedToScreen(true)


-- Create the UI for the NPM list frame
local closeFrameButton = CreateFrame("Button", "closeFrameBtn", npcListFrame, "UIPanelButtonTemplate")
closeFrameButton:SetText("Close")
closeFrameButton:SetPoint( "BOTTOMRIGHT")
closeFrameButton:SetScript("OnClick", function (self, button, down)
  npcListFrame:Hide()
 end)
 closeFrameButton:SetSize(131, 21)


--  Hide the complete frame
npcListFrame:Hide()

function addon:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
  
  self.db = LibStub("AceDB-3.0"):New("EarmuffsDB")

  self.db:RegisterDefaults({
    global = {
      blockSayNPC = true,
      blockYellsNPC = true,
      blockYellsPlayer = false,
      tableNPCs = {},
    }
  })
    
  self:createTableFromDefaults()

  
  -- add chat filter for npc says
  ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", Earmuffs_MsgFilter);
  -- add chat filter for npc yells
  ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", Earmuffs_MsgFilter);
  -- add chat filter for player yells
  ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Earmuffs_MsgFilter);

end

function addon:OnEnable()
    -- Called when the addon is enabled
end

function addon:OnDisable()
    -- Called when the addon is disabled
end

--------------------------------------------------------------------------------
-- Initialize the npcSay table
function addon:createTableFromDefaults()

  local t = addon.db.global.tableNPCs
  
  -- Reset the table
  wipe(self.db.global.tableNPCs)

  -- Populate the tblNpcSay table

  -- Block says from npcs  
  table.insert(t, "Topper McNabb");
  table.insert(t, "Morris Lawry");
  
  -- Celestial court noodle vendors
  table.insert(t, "Brother Noodle");
  table.insert(t, "Great Chef Woo");
  table.insert(t, "Sapmaster Vu");
  table.insert(t, "Hearthminder Digao");
  table.insert(t, "Master Miantiao");
  table.insert(t, "Noodle-Maker Monmon");
  table.insert(t, "Brewmaster Tzu");
  table.insert(t, "Big Dan Stormstout");
  table.insert(t, "Galu Wellspring");
  table.insert(t, "Grimthorn Redbeard");
  table.insert(t, "Crafter Kwon");
  table.insert(t, "Smiling Jade");
  table.insert(t, "Graceful Swan");
  table.insert(t, "Drix Blackwrench");
  
  --Garrison NPCs
  table.insert(t, "Scout Valdez");

end

function addon:dumpDB()

   for i,npc in ipairs(self.db.global.tableNPCs) do
        self:Print(npc);
   end
end

function addon:toggleNPCList()

  if npcListFrame:IsVisible() then
    npcListFrame:Hide()
else
  npcListFrame:Show()
end

end

function addon:reloadDB()

  self:createTableFromDefaults()
  self:Print("NPC database reloaded")
end

function addon:getOption(info)
  return self.db.global[info[#info]]
end

function addon:setOption(info, value)
  --message(tostring(info).." "..tostring(value))
  self.db.global[info[#info]] = value
end

-- this is the chat filter that hides the chat messages we don't want.
function Earmuffs_MsgFilter(self, event, msg, author, ...)
  --message("Earmuffs: "..author);
    -- print the lines
    if event == "CHAT_MSG_MONSTER_SAY" 
      and addon.db.global.blockSayNPC == true then 
      for i,npc in ipairs(addon.db.global.tableNPCs) do
        if author == npc then 
          return true
        end
      end
      return false
    end
      
    -- Block all yells from NPCs
    if event == "CHAT_MSG_MONSTER_YELL" 
      and addon.db.global.blockYellsNPC == true then 
        return true
    end
    
    -- Block all yells from players
    if event == "CHAT_MSG_YELL" 
      and addon.db.global.blockYellsPlayer == true then 
        return true
    end
end
