local PANEL = {}
local xmh_module_title = "XMHText 1.1"

-- Font
if system.IsWindows() then 
  surface.CreateFont("XMHDefault", {
    font    = "Tahoma",
    size    = 14,
    weight  = 400,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
  })
else
  surface.CreateFont("XMHDefault", {
    font    = "Tahoma",
    size    = 15,
    weight  = 400,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
  })
end

-- ---------------
-- Initializing
-- ---------------
function PANEL:Init()
  local Width = 800
  local TextAreaHeight = 420
  local ButtonHeight = 20

  -- PANEL 1
  local EntryPanel = vgui.Create("DPanel",self)
  EntryPanel:SetPos(5,23 + 5)
  EntryPanel:SetTall(5 + TextAreaHeight + 5)
  EntryPanel:SetWide(Width)

  -- "Scrollbar"
  local ScrollPanel = vgui.Create("DScrollPanel",EntryPanel)
  ScrollPanel:SetPos(0,5)
  ScrollPanel:SetTall(TextAreaHeight)
  ScrollPanel:SetWide(Width - 5)

  -- Textarea
  local TextEntry = vgui.Create("DTextEntry",ScrollPanel)
  TextEntry:SetPos(5,0)
  TextEntry:SetTall(TextAreaHeight)
  TextEntry:SetWide(EntryPanel:GetWide() - 5 - 5)
  TextEntry:SetEnterAllowed(true)
  TextEntry:SetMultiline(true)
  TextEntry:SetAllowNonAsciiCharacters(true)
  TextEntry:SetFont("XMHDefault")

  -- -- --
  local X,Y = EntryPanel:GetPos()
  -- -- --

  -- PANEL 2
  local ButtonPanel = vgui.Create("DPanel",self)
  ButtonPanel:SetPos(5,Y + EntryPanel:GetTall() + 5)
  ButtonPanel:SetTall(5 + ButtonHeight + 5)
  ButtonPanel:SetWide(Width)

  -- Close button
  local CanButton = vgui.Create("DButton",ButtonPanel)
  CanButton:SetPos(ButtonPanel:GetWide() - 150 - 5,5)
  CanButton:SetSize(150, ButtonHeight)
  CanButton:SetText(XMH_LANG[LANG]["xmhtext_close"])
  CanButton:SetFont("XMHDefault")

  -- Label
  local DLabel = vgui.Create("DLabel", ButtonPanel)
  DLabel:SetPos(5, 5)
  DLabel:SetWide(ButtonPanel:GetWide() - 150 - 5)
  DLabel:SetText(XMH_LANG[LANG]["xmhtext_details"])
  DLabel:SetDark(1)
  DLabel:SetFont("XMHDefault")

  -- -- --
  local X,Y = ButtonPanel:GetPos()
  -- -- --

  -- Window
  self:SetTitle(xmh_module_title)
  self:SetTall(Y + ButtonPanel:GetTall() + 5)
  self:SetWide(EntryPanel:GetWide() + 5 + 5)
  self:ShowCloseButton(false)
  
  -- Pointing
  self.EntryPanel  = EntryPanel
  self.ScrollPanel = ScrollPanel
  self.TextEntry   = TextEntry
  self.ButtonPanel = ButtonPanel
  self.CanButton   = CanButton
  self.DLabel      = DLabel
  self.FontWidth, self.FontHeight = surface.GetTextSize(" ");

  -- Functions
  self:SetupEvents()
  self:CreateFolder()
  self:SetEntryValue()
  self:MakePopup()
  self:Center()
  self:Scroll()
end

-- ---------------
-- Actions
-- ---------------
function PANEL:SetupEvents()
  local Form = self
  local Text = self:GetEntryValue()

  -- scroll
  self.TextEntry.OnEnter = function()
    Form:Scroll()
  end

  timer.Create("RidiculousAutoScroll",3,0,function()
    Form:Scroll()
  end)

  -- autosave
  function AutoSave()
    Form:ApplyEdit(Text)
    Text = Form:GetEntryValue()
  end

  timer.Create("TextAutosave",10,0,function()
    AutoSave()
  end)

  -- close
  function self.CanButton:DoClick()
    Form:EndEdit(Text)
  end
end

-- ---------------
-- XMH folder
-- ---------------
function PANEL:CreateFolder()
  if !file.Exists(xmh_folder, "DATA") then
    file.CreateDir(xmh_folder)
  end
end

-- ---------------
-- Get text
-- ---------------
function PANEL:GetEntryValue()
  return self.TextEntry:GetValue()
end

-- ---------------
-- Set text
-- ---------------
function PANEL:SetEntryValue()
  local Text
  
  if !file.Exists(xmh_text_file, "DATA") then
    self.TextEntry:SetValue(XMH_LANG[LANG]["xmhtext_initial_text"])
  else
    Text = file.Read(xmh_text_file, "DATA")
    self.TextEntry:SetValue(Text)
  end
end

-- ---------------
-- Save
-- ---------------
function PANEL:ApplyEdit(Text)
  local Text2 = self:GetEntryValue()
  
  if Text != Text2 then
    file.Write(xmh_text_file, Text2)
    self:SetTitle(xmh_module_title..XMH_LANG[LANG]["xmhtext_saving"])
    timer.Create("SaveMsgRestore",1,1,function()
      self:SetTitle(xmh_module_title)
    end)
  end
end

-- ---------------
-- "Scrollbar"
-- ---------------
function PANEL:Scroll()
  local Text = self:GetEntryValue()
  local Lines = 1
  local playerInput = string.Explode("\n", Text)

  while (playerInput[Lines] != nil) do
    Lines = Lines + 1
  end

  if (Lines - 1 > 28) then
    self.TextEntry:SetTall(Lines * 15)
  elseif (self.TextEntry:GetTall() > 28 * 15) then
    self.TextEntry:SetTall(28 * 15)
  end
end

-- ---------------
-- Close
-- ---------------
function PANEL:EndEdit(Text)
  local Text2 = self:GetEntryValue()
  
  if Text != Text2 then
    file.Write(xmh_text_file, Text2)
  end
  timer.Destroy("TextAutosave")
  timer.Destroy("RidiculousAutoScroll")
  self:Close()
end

-- ---------------
-- Open
-- ---------------
local function OpenMenu()
  vgui.Create("XMHTextMenu")
end 

vgui.Register("XMHTextMenu",PANEL,"DFrame")

concommand.Add("xmh_texteditor",OpenMenu)
