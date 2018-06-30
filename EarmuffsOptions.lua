-- create a interface options panel
local addonName, addon = ...
if not addon.healthCheck then return end
local L = addon.L

local wow_ver = select(4, GetBuildInfo())
local wow_500 = wow_ver >= 50000
local UIPanelButtonTemplate = wow_500 and "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

local optionsFrame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
optionsFrame.name = addonName
optionsFrame:Hide()
