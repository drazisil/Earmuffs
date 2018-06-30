-- create a frame to listen to game events
--local mainFrame, mainFrameEvents = CreateFrame("FRAME"), {};

-- Create the Ace3 addon
Earmuffs = LibStub("AceAddon-3.0"):NewAddon("Earmuffs", "AceConsole-3.0", "AceEvent-3.0")

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
        status = {
            type = 'execute',
            name = 'Status',
            desc = 'display the current status',
            func = 'displayStatus',
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
				moo = {
          order	= 5,
          type	= "description",
          name	= "Moo!",
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

function Earmuffs:displayStatus()
    Earmuffs:Print("Status is currently: "..tostring(Earmuffs.db.global.enabled))end

function Earmuffs:OnInitialize()
  -- Code that you want to run when the addon is first loaded goes here.
  
  Earmuffs.db = LibStub("AceDB-3.0"):New("EarmuffsDB")
  
  -- Set defaults
  if self.db.global.enabled == nil then 
    self.db.global.emabled = true 
  end
  
  if self.db.global.blockSayNPC == nil then 
    self.db.global.blockSayNPC = true 
  end
  
  if self.db.global.blockYellsNPC == nil then 
    self.db.global.blockYellsNPC = true 
  end
  
  if self.db.global.blockYellsPlayer == nil then 
    self.db.global.blockYellsPlayer = false 
  end

  
  -- Create the table to hold the npcs we want to block says for
  if Earmuffs.db.global.tableNPCs == nil 
    or Earmuffs.db.global.tableNPCs.getn == nil then
    
    Earmuffs.db.global.tableNPCs = {};
    Earmuffs.createTableFromDefaults()
  end
  
  -- add chat filter for npc says
  ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", Earmuffs_MsgFilter);
  -- add chat filter for npc yells
  ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", Earmuffs_MsgFilter);
  -- add chat filter for player yells
  ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Earmuffs_MsgFilter);

end

function Earmuffs:OnEnable()
    -- Called when the addon is enabled
end

function Earmuffs:OnDisable()
    -- Called when the addon is disabled
end

--------------------------------------------------------------------------------
-- Initialize the npcSay table
function Earmuffs.createTableFromDefaults()

  -- Reset the table
  local t = {};

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
  
  Earmuffs.db.global.tableNPCs = t

end

function Earmuffs:dumpDB()

   for i,npc in ipairs(Earmuffs.db.global.tableNPCs) do
        Earmuffs:Print(npc);
   end
end

function Earmuffs:reloadDB()

  self:createTableFromDefaults()
  self:Print("NPC database reloaded")
end

function Earmuffs:getOption(info)
  return self.db.global[info[#info]]
end

function Earmuffs:setOption(info, value)
  --message(tostring(info).." "..tostring(value))
  self.db.global[info[#info]] = value
end

-- this is the chat filter that hides the chat messages we don't want.
function Earmuffs_MsgFilter(self, event, msg, author, ...)
  --message("Earmuffs: "..author);
    -- print the lines
    if event == "CHAT_MSG_MONSTER_SAY" 
      and Earmuffs.db.global.blockSayNPC == true then 
      for i,npc in ipairs(Earmuffs.db.global.tableNPCs) do
        if author == npc then 
          return true
        end
      end
      return false
    end
      
    -- Block all yells from NPCs
    if event == "CHAT_MSG_MONSTER_YELL" 
      and Earmuffs.db.global.blockYellsNPC == true then 
        return true
    end
    
    -- Block all yells from players
    if event == "CHAT_MSG_YELL" 
      and Earmuffs.db.global.blockYellsPlayer == true then 
        return true
    end
end
