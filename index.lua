
-- ULTIMATE | Universal FPS Utility
-- Single-file Lua UI | Black x Deep Electric Blue
-- Visual changes are client-side and may vary by game.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local C = {
    bg = Color3.fromRGB(5, 10, 18),
    panel = Color3.fromRGB(9, 20, 33),
    row = Color3.fromRGB(12, 29, 47),
    border = Color3.fromRGB(22, 78, 131),
    blue = Color3.fromRGB(22, 139, 255),
    cyan = Color3.fromRGB(112, 213, 255),
    text = Color3.fromRGB(234, 246, 255),
    muted = Color3.fromRGB(91, 155, 203),
}

local oldGui = PlayerGui:FindFirstChild("ULTIMATE_UI")
if oldGui then oldGui:Destroy() end

local saved = {}
local connections = {}
local enabled = {}
local collapsed = {}
local minimized = false
local maximized = false
local closed = false

local function save(obj, prop)
    saved[obj] = saved[obj] or {}
    if saved[obj][prop] == nil then
        pcall(function()
            saved[obj][prop] = obj[prop]
        end)
    end
end

local function setProp(obj, prop, value)
    save(obj, prop)
    pcall(function()
        obj[prop] = value
    end)
end

local function restore()
    for obj, props in pairs(saved) do
        if obj and obj.Parent then
            for prop, value in pairs(props) do
                pcall(function()
                    obj[prop] = value
                end)
            end
        end
    end
    table.clear(saved)
    table.clear(enabled)
end

local function tween(obj, props, duration)
    local ok, result = pcall(function()
        local t = TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart,
                Enum.EasingDirection.Out),
            props
        )
        t:Play()
        return t
    end)
    return ok and result or nil
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local gui = make("ScreenGui", {
    Name = "ULTIMATE_UI",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local main = make("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(330, 440),
    Position = UDim2.new(0.5, -165, 0.5, -220),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, gui)

make("UICorner", {CornerRadius = UDim.new(0, 9)}, main)
make("UIStroke", {
    Color = C.border,
    Thickness = 1,
    Transparency = 0.08,
}, main)

-- Moving electric streak along the left edge.
local edge = make("Frame", {
    Name = "ElectricEdge",
    Size = UDim2.new(0, 2, 0, 70),
    Position = UDim2.new(0, 0, 0, -70),
    BackgroundColor3 = C.cyan,
    BorderSizePixel = 0,
    ZIndex = 10,
}, main)

make("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(0.5, C.cyan),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
    }),
}, edge)

local edgeLoop = tween(edge, {
    Position = UDim2.new(0, 0, 1, 0)
}, 2.1)

task.spawn(function()
    while gui.Parent do
        edge.Position = UDim2.new(0, 0, 0, -70)
        tween(edge, {
            Position = UDim2.new(0, 0, 1, 0)
        }, 2.1)
        task.wait(2.15)
    end
end)

-- Header
local header = make("Frame", {
    Size = UDim2.new(1, 0, 0, 49),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)

local title = make("TextLabel", {
    Position = UDim2.fromOffset(14, 0),
    Size = UDim2.new(1, -145, 1, 0),
    BackgroundTransparency = 1,
    Text = "ULTIMATE",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
}, header)

local function topButton(text, x)
    local b = make("TextButton", {
        Position = UDim2.new(1, x, 0, 10),
        Size = UDim2.fromOffset(27, 27),
        BackgroundColor3 = C.row,
        Text = text,
        TextColor3 = C.cyan,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    }, header)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, b)
    make("UIStroke", {Color = C.border, Thickness = 1}, b)
    return b
end

local minimizeBtn = topButton("−", -99)
local maximizeBtn = topButton("□", -65)
local closeBtn = topButton("×", -31)

local sub = make("TextLabel", {
    Position = UDim2.fromOffset(14, 49),
    Size = UDim2.new(1, -28, 0, 20),
    BackgroundTransparency = 1,
    Text = "UNIVERSAL FPS BOOST",
    TextColor3 = C.muted,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, main)

local body = make("ScrollingFrame", {
    Position = UDim2.fromOffset(10, 73),
    Size = UDim2.new(1, -20, 1, -126),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 3,
    ScrollBarImageColor3 = C.blue,
    CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)

make("UIPadding", {
    PaddingTop = UDim.new(0, 3),
    PaddingBottom = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 3),
}, body)

make("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, body)

local function section(name)
    local wrap = make("Frame", {
        Size = UDim2.new(1, -3, 0, 34),
        BackgroundColor3 = C.panel,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, body)
    make("UICorner", {CornerRadius = UDim.new(0, 5)}, wrap)
    make("UIStroke", {Color = C.border, Thickness = 1, Transparency = 0.25}, wrap)

    local button = make("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        Text = name .. "     +",
        TextColor3 = C.text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    }, wrap)

    make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 8),
    }, button)

    local content = make("Frame", {
        Position = UDim2.fromOffset(5, 35),
        Size = UDim2.new(1, -10, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, wrap)

    local list = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, content)

    local opened = false
    local function update(animate)
        opened = not opened
        button.Text = name .. (opened and "     −" or "     +")
        local height = opened and (39 + list.AbsoluteContentSize.Y) or 34
        tween(wrap, {Size = UDim2.new(1, -3, 0, height)}, animate and 0.22 or 0)
        tween(content, {
            Size = UDim2.new(1, -10, 0, opened and list.AbsoluteContentSize.Y or 0)
        }, animate and 0.22 or 0)
    end

    button.Activated:Connect(function()
        update(true)
    end)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if opened then update(false); update(false) end
    end)

    return content, function()
        if not opened then update(true) end
    end
end

local function addToggle(parent, label, callback, default)
    enabled[label] = default or false

    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 31),
        BackgroundColor3 = C.row,
        BorderSizePixel = 0,
    }, parent)
    make("UICorner", {CornerRadius = UDim.new(0, 4)}, row)

    local txt = make("TextLabel", {
        Position = UDim2.fromOffset(9, 0),
        Size = UDim2.new(1, -62, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local toggle = make("TextButton", {
        Position = UDim2.new(1, -44, 0.5, -8),
        Size = UDim2.fromOffset(34, 16),
        BackgroundColor3 = default and C.blue or Color3.fromRGB(35, 48, 62),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, row)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, toggle)

    local dot = make("Frame", {
        Size = UDim2.fromOffset(12, 12),
        Position = default and UDim2.new(1, -14, 0.5, -6)
            or UDim2.fromOffset(2, 2),
        BackgroundColor3 = C.text,
        BorderSizePixel = 0,
    }, toggle)
    make("UICorner", {CornerRadius = UDim.new(1, 0)}, dot)

    local function apply(state)
        enabled[label] = state
        tween(toggle, {
            BackgroundColor3 = state and C.blue
                or Color3.fromRGB(35, 48, 62)
        }, 0.16)
        tween(dot, {
            Position = state and UDim2.new(1, -14, 0.5, -6)
                or UDim2.fromOffset(2, 2)
        }, 0.16)
        if callback then
            local ok, err = pcall(callback, state)
            if not ok then warn("[ULTIMATE] " .. label .. ": " .. tostring(err)) end
        end
    end

    toggle.Activated:Connect(function()
        apply(not enabled[label])
    end)

    return apply
end

-- Visual optimizers. Only properties changed by this script are saved.
local function eachDescendant(callback)
    for _, obj in ipairs(game:GetDescendants()) do
        callback(obj)
    end
end

local fix, openFix = section("FIX LAG")
local misc, openMisc = section("MISC")
local status, openStatus = section("STATUS")

addToggle(fix, "Low Graphics", function(on)
    pcall(function()
        settings().Rendering.QualityLevel = on
            and Enum.QualityLevel.Level01
            or Enum.QualityLevel.Automatic
    end)
    setProp(Lighting, "GlobalShadows", not on)
end)

addToggle(fix, "Remove Textures", function(on)
    eachDescendant(function(obj)
        if obj:IsA("Texture") or obj:IsA("Decal") then
            setProp(obj, "Transparency", on and 1 or (saved[obj] and saved[obj].Transparency or 0))
        end
    end)
end)

addToggle(fix, "Remove Decals", function(on)
    eachDescendant(function(obj)
        if obj:IsA("Decal") then
            setProp(obj, "Transparency", on and 1 or (saved[obj] and saved[obj].Transparency or 0))
        end
    end)
end)

addToggle(fix, "Reduce Particles", function(on)
    eachDescendant(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
        or obj:IsA("Beam") or obj:IsA("Fire")
        or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            setProp(obj, "Enabled", not on)
        end
    end)
end)

addToggle(fix, "Disable Shadows", function(on)
    eachDescendant(function(obj)
        if obj:IsA("BasePart") then
            setProp(obj, "CastShadow", not on)
        end
    end)
    setProp(Lighting, "GlobalShadows", not on)
end)

addToggle(fix, "Disable Fog", function(on)
    setProp(Lighting, "FogEnd", on and 1000000 or 1000)
    setProp(Lighting, "FogStart", on and 0 or 0)
    eachDescendant(function(obj)
        if obj:IsA("Atmosphere") then
            setProp(obj, "Density", on and 0 or (saved[obj] and saved[obj].Density or 0.3))
            setProp(obj, "Haze", on and 0 or (saved[obj] and saved[obj].Haze or 1))
        end
    end)
end)

addToggle(fix, "Disable Post-Processing", function(on)
    eachDescendant(function(obj)
        if obj:IsA("PostEffect") then
            setProp(obj, "Enabled", not on)
        end
    end)
end)

addToggle(fix, "Preserve Colors", function(on)
    -- Informational toggle: does not rewrite object colors.
    -- Avoids destructive material/color edits.
end, true)

addToggle(misc, "Fullbright", function(on)
    if on then
        setProp(Lighting, "Brightness", 2)
        setProp(Lighting, "ClockTime", 14)
        setProp(Lighting, "Ambient", Color3.new(1, 1, 1))
        setProp(Lighting, "OutdoorAmbient", Color3.new(1, 1, 1))
    else
        for prop, value in pairs(saved[Lighting] or {}) do
            pcall(function() Lighting[prop] = value end)
        end
    end
end)

addToggle(misc, "Infinite Camera Zoom", function(on)
    setProp(Player, "CameraMaxZoomDistance", on and 1000000 or 128)
end)

addToggle(misc, "No Camera Shake", function(on)
    -- Game-specific camera shake cannot be disabled universally.
    if on then
        warn("[ULTIMATE] No Camera Shake may require game-specific support.")
    end
end)

addToggle(misc, "Animation Toggle", function(on)
    -- Controls this UI's motion preference.
    gui:SetAttribute("AnimationsEnabled", not on)
end)

local fpsLabel = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "FPS: --",
    TextColor3 = C.text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)

local pingLabel = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "PING: --",
    TextColor3 = C.text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)

local memLabel = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "MEMORY: --",
    TextColor3 = C.text,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
}, status)

local footer = make("Frame", {
    Position = UDim2.new(0, 10, 1, -47),
    Size = UDim2.new(1, -20, 0, 37),
    BackgroundColor3 = C.panel,
    BorderSizePixel = 0,
}, main)
make("UICorner", {CornerRadius = UDim.new(0, 5)}, footer)
make("UIStroke", {Color = C.border, Thickness = 1, Transparency = 0.25}, footer)

make("TextLabel", {
    Position = UDim2.fromOffset(8, 2),
    Size = UDim2.new(1, -16, 0, 15),
    BackgroundTransparency = 1,
    Text = "ULTIMATE FEEDBACK",
    TextColor3 = C.text,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, footer)

make("TextLabel", {
    Position = UDim2.fromOffset(8, 17),
    Size = UDim2.new(1, -16, 0, 15),
    BackgroundTransparency = 1,
    Text = "TIKTOK: @puntech.user",
    TextColor3 = C.cyan,
    Font = Enum.Font.Gotham,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
}, footer)

-- Drag window using mouse or touch.
do
    local dragging, startInput, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = main.Position
        end
    end)

    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Minimize to a small floating button.
local miniButton
minimizeBtn.Activated:Connect(function()
    if minimized then return end
    minimized = true
    miniButton = make("TextButton", {
        Name = "ULTIMATE_REOPEN",
        Size = UDim2.fromOffset(105, 35),
        Position = main.Position,
        BackgroundColor3 = C.panel,
        Text = "ULTIMATE  +",
        TextColor3 = C.cyan,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, gui)
    make("UICorner", {CornerRadius = UDim.new(0, 7)}, miniButton)
    make("UIStroke", {Color = C.blue, Thickness = 1}, miniButton)
    main.Visible = false
    miniButton.Activated:Connect(function()
        main.Visible = true
        minimized = false
        miniButton:Destroy()
    end)
end)

local normalSize = main.Size
maximizeBtn.Activated:Connect(function()
    maximized = not maximized
    if maximized then
        main.Size = UDim2.new(1, -24, 1, -50)
        main.Position = UDim2.fromOffset(12, 25)
        maximizeBtn.Text = "❐"
    else
        main.Size = normalSize
        main.Position = UDim2.new(0.5, -165, 0.5, -220)
        maximizeBtn.Text = "□"
    end
end)

closeBtn.Activated:Connect(function()
    if closed then return end
    closed = true
    restore()
    tween(main, {BackgroundTransparency = 1}, 0.12)
    task.wait(0.13)
    gui:Destroy()
end)

-- Live status readings.
local frames, elapsed = 0, 0
connections.fps = RunService.RenderStepped:Connect(function(dt)
    frames += 1
    elapsed += dt
    if elapsed >= 1 then
        fpsLabel.Text = "FPS: " .. tostring(math.floor(frames / elapsed + 0.5))
        frames, elapsed = 0, 0
    end
end)

connections.status = task.spawn(function()
    while gui.Parent do
        local ok, value = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
        end)
        pingLabel.Text = "PING: " .. (ok and tostring(value) or "N/A")

        local okMem, memory = pcall(function()
            return Stats:GetTotalMemoryUsageMb()
        end)
        memLabel.Text = "MEMORY: " ..
            (okMem and string.format("%.1f MB", memory) or "N/A")

        task.wait(1.5)
    end
end)

-- Start with FIX LAG expanded.
openFix()
print("[ULTIMATE] UI loaded.")
