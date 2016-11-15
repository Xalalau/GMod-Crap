-- Adicionar controle do tamanho da fonte
-- Adicionar aviso de bind

-- ---------------
-- Globals
-- ---------------
local XMHPANEL = {}

local xmh_module_title = "XMHText 2.0"

local window = {
    char_height = 17,
    char_width = 8.572,
    height = 401, 
    width = 600, -- 8.572 /600 ~= (70 characters per line) 
    text_default_height = 401 - 44, -- 401(height) - 44(correction) = 357 = (21 lines) * 17(char_height)
    text_new_height = nil, -- SetScroll()
    pos_x = nil, -- SaveSizePos()
    pos_y = nil, -- SaveSizePos()
    text = nil, -- LoadText() and SaveText()
    reload = false, -- SetScroll()
    saving_msg = true, -- SetScroll()
}

CreateClientConVar("xmh_textfont_var", 16, false, false)

-- ---------------
-- Init
-- ---------------
function XMHPANEL:Init()
    self:CreateFont()  
    self:SetPanel()
    self:SetEvents()
    self:LoadText()
    self:SetScroll()
end

-- ---------------
-- Create font
-- ---------------
function XMHPANEL:CreateFont()
    -- Monospaced font
    surface.CreateFont( "XMHDefault", {
        font = "Courier New",
        size = GetConVar("xmh_textfont_var"):GetInt(),
        weight = 400,
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
    } )
end

-- ------------------
-- Populate the panel
-- ------------------
function XMHPANEL:SetPanel()
    -- WINDOW
    self:SetTitle( xmh_module_title )
    self:SetTall( window.height )
    self:SetWide( window.width )
    self:ShowCloseButton( true )
    self:SetDeleteOnClose( false )
    self:SetSizable( true )
    self:MakePopup()
    if ( window.pos_x && window.pos_y ) then
        self:SetPos( window.pos_x, window.pos_y )
    else
        self:Center()
    end
    self.btnMinim:Hide()
    self.btnMaxim:SetEnabled( true )

    -- ELEMENTS
    local TextPanel = vgui.Create( "DPanel", self )
        TextPanel:Dock( FILL )
    local Scroll = vgui.Create( "DScrollPanel", TextPanel )
        Scroll:Dock( FILL )
        Scroll:DockMargin( 5, 5, 5, 5 )
    local TextEntry = vgui.Create( "DTextEntry", Scroll )
        TextEntry:SetTall( window.text_default_height * 3 )
        TextEntry:Dock( FILL )
        TextEntry:SetEnterAllowed( true )
        TextEntry:SetMultiline( true )
        TextEntry:SetAllowNonAsciiCharacters( true )
        TextEntry:SetUpdateOnType( true )
        TextEntry:SetFont( "XMHDefault" )

    -- EXTERNING ELEMENTS
    self.TextPanel = TextPanel
    self.Scroll = Scroll
    self.TextEntry = TextEntry    
end

-- ---------------
-- Set events
-- ---------------
function XMHPANEL:SetEvents()
    -- scrolling
    self.TextEntry.OnValueChange = function()
        self:SetScroll()
    end

    -- autosave text
    timer.Create( "UpdateFont", 1, 0, function()
        self:SetFont( true )
    end)

    -- autosave text
    timer.Create( "TextAutosave", 10, 0, function()
        self:SaveText()
    end)

    -- autosave size and position
    timer.Create( "WindowKeepPosSize", 1, 0, function()
        self:SaveSizePos()
    end)
    
    -- maximize
    self.btnMaxim.DoClick = function ( button )
        self:Maximize()
    end

    -- on close
    function self:OnClose()
        self:Exit()
    end
end

-- ---------------
-- Load text
-- ---------------
function XMHPANEL:LoadText()
    if not ( file.Exists( xmh_text_file, "DATA" ) ) then
        self.TextEntry:SetValue( XMH_LANG[LANG]["xmhtext_initial_text"] )
    else
        window.text = file.Read( xmh_text_file, "DATA" )
        self.TextEntry:SetValue( window.text )
    end
end

-- ---------------
-- Scrollbar
-- ---------------
function XMHPANEL:SetScroll()
    local text = self.TextEntry:GetValue()
    local chars_per_line_limit = math.Round( self:GetWide() / window.char_width ) - 1 -- I have to subtract 1 to compensate the scrollbar
    local lines_limit = math.Round( self.TextEntry:GetTall() / window.char_height )
    local chars_counting = 0
    local lines_counting = 1
    local ch = 1

    while ( text[ch] != '' ) do
        if ( ( text[ch] == '\n' ) or ( chars_counting == chars_per_line_limit ) ) then
            lines_counting = lines_counting + 1
            chars_counting = 0
        end
        chars_counting = chars_counting + 1
        ch = ch + 1
    end

    local text_new_height = self.TextEntry:GetTall() + ( lines_counting - lines_limit ) * window.char_height

    if ( ( lines_counting > lines_limit ) && ( text_new_height != window.text_new_height ) ) then
        window.text_new_height = text_new_height + window.text_default_height
        self.TextEntry:SetTall( window.text_new_height )
        if ( window.reload == true ) then
            if not ( timer.Exists( "BadAutoScroll" ) ) then
                local counting = 5
                timer.Create("Warning",1,5,function()
                    self:SetTitle( xmh_module_title .. XMH_LANG[LANG]["xmhtext_warning_reload"] .. counting )
                    counting = counting - 1
                end)
                timer.Create("BadAutoScroll",6,1,function()
                    window.saving_msg = true
                    if ( self:IsActive() ) then
                        self:Close()
                        OpenMenu()
                    end
                end)
                window.reload = false
                window.saving_msg = false
            end
        else
            window.reload = true
        end
    end
end

-- ---------------
-- Save text
-- ---------------
function XMHPANEL:SaveText()
    local text2 = self.TextEntry:GetValue()

    if ( window.text != text2 ) then
        file.Write( xmh_text_file, text2 )
        if ( window.saving_msg ) then
            self:SetTitle( xmh_module_title .. XMH_LANG[LANG]["xmhtext_saving"] )
            timer.Create( "SaveMsgRestore", 1, 1, function()
                self:SetTitle( xmh_module_title )
            end)
        end
        window.text = text2
    end
end

-- ---------------
-- Save size & pos
-- ---------------
function XMHPANEL:SaveSizePos()
    if ( ( self:GetWide() != ScrW() ) && ( self:GetTall() != ScrH() ) ) then
        if ( window.width != self:GetWide() ) then
            window.width = self:GetWide()
        end
        if ( window.height != self:GetTall() ) then
            window.height = self:GetTall()
        end
        local x, y = self:GetPos()
        if ( ( window.pos_x != x ) || ( window.pos_y != y ) ) then
            window.pos_x, window.pos_y = self:GetPos()
        end
    end
end

-- ---------------
-- Set font size
-- ---------------
function XMHPANEL:SetFont()
    if ( GetConVar("xmh_textfont_var"):GetInt() != 16 ) then
        local font_width, font_height = surface.GetTextSize(" ");
        if ( ( font_width != window.char_width ) && ( font_height != window.char_height ) ) then
            window.char_height = font_height
            window.char_width = font_width
            self:CreateFont( true )
        end
    elseif ( window.char_width != 8.572 ) then
        window.char_height = 17
        window.char_width = 8.572
    end
end

-- ---------------
-- Maximize
-- ---------------
function XMHPANEL:Maximize()
    if ( self:GetWide() == ScrW() ) then
        self:SetSize( window.width, window.height )
        if ( window.pos_x && window.pos_y ) then
            self:SetPos( window.pos_x, window.pos_y )
        else
            self:Center()
        end
    else
        self:SetSize( ScrW(), ScrH() )
        self:Center()
    end
end

-- ---------------
-- Exit
-- ---------------
function XMHPANEL:Exit()
    self:SaveText()
    timer.Destroy( "TextAutosave" )
    timer.Destroy( "WindowKeepPosSize" )
    timer.Destroy( "UpdateFont" )
end

-- ---------------
-- Open
-- ---------------
function OpenMenu()
    vgui.Create( "XMHTextMenu" )
end 

vgui.Register( "XMHTextMenu", XMHPANEL, "DFrame" )

concommand.Add( "xmh_texteditor", OpenMenu )
