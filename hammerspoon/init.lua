-- 定义 Hyper 键别名
local hyper = {"cmd", "alt", "ctrl", "shift"}
hs.alert.show("Config Loaded 🚀")

-- 快速分屏：左半屏、右半屏、全屏
hs.hotkey.bind(hyper, "Left", function()
    hs.window.focusedWindow():moveToUnit(hs.geometry.rect(0, 0, 0.5, 1))
end)

hs.hotkey.bind(hyper, "Right", function()
    hs.window.focusedWindow():moveToUnit(hs.geometry.rect(0.5, 0, 0.5, 1))
end)

hs.hotkey.bind(hyper, "Up", function()
    local win = hs.window.focusedWindow()
    
    if win then
        -- 情况 1：窗口已有焦点，直接最大化
        win:maximize()
    else
        -- 情况 2：当前没有焦点窗口，尝试寻找并恢复当前最前端应用的最小化窗口
        local app = hs.application.frontmostApplication()
        if app then
            local windows = app:allWindows()
            for _, w in ipairs(windows) do
                if w:isMinimized() then
                    w:unminimize()
                    w:focus()
                    -- 延迟一小段时间等待系统完成恢复动画，再执行最大化
                    hs.timer.doAfter(0.1, function()
                        w:maximize()
                    end)
                    return -- 处理完第一个就跳出
                end
            end
        end
        hs.alert.show("没有可操作的窗口")
    end
end)

hs.hotkey.bind(hyper, "Down", function()
    hs.window.focusedWindow():minimize()
end)

local appMap = {
    T = "iTerm",       -- 也可以换成 iTerm / Alacritty
    B = "Google Chrome",
    F = "Finder",
    V = "Visual Studio Code",
}

for key, app in pairs(appMap) do
    hs.hotkey.bind(hyper, key, function()
        hs.application.launchOrFocus(app)
    end)
end

 
-- Hyper + R: 锁屏 (等同于 Cmd+Ctrl+Q)
hs.hotkey.bind(hyper, "Q", function()
    hs.caffeinate.lockScreen()
end)

-- Hyper + M: 快速静音/取消静音
hs.hotkey.bind(hyper, "M", function()
    local dev = hs.audiodevice.defaultOutputDevice()
    dev:setMuted(not dev:muted())
    if dev:muted() then hs.alert.show("Muted 🔇") else hs.alert.show("Unmuted 🔊") end
end)

-- Hyper + P: 剪贴板历史清理（防止某些敏感信息停留太久）
hs.hotkey.bind(hyper, "P", function()
    hs.pasteboard.clearContents()
    hs.alert.show("Pasteboard Cleared")
end)


-- 定义输入法 ID 变量（请根据第一步获取的结果替换）
local English = "com.apple.keylayout.ABC"
local lastSource = nil -- 用于保存切走之前的输入法 ID

-- 指定需要使用英文的应用名称
local app2English = {
    ["Terminal"] = true,
    ["iTerm2"] = true,
    ["Ghostty"] = true,
    ["Visual Studio Code"] = true,
    ["Code"] = true, -- vscode
    ["Xcode"] = true,
    ["Finder"] = true,
    ["Zed"] = true,
}
-- 通用窗口切换逻辑
wf = hs.window.filter.new()
wf:subscribe(hs.window.filter.windowFocused, function(window)
    local appName = window:application():name()
    local currentSource = hs.keycodes.currentSourceID()
    if app2English[appName] then
        if currentSource ~= English then
            lastSource = currentSource
        end
        hs.keycodes.currentSourceID(English)
    else
        if lastSource then
            hs.keycodes.currentSourceID(lastSource)
            lastSource = nil
        end
    end
end)


-- 接通电源恢复亮度
-- 1. 将状态存入全局表，确保生命周期安全
hs.lastPowerStatus = hs.battery.powerSource()

-- 2. 封装一个设置函数，方便初始化和回调共用
local function updateBrightness()
    local currentStatus = hs.battery.powerSource()
    local isAC = (currentStatus == "AC Power")
    
    if isAC then
        hs.brightness.set(90)
        -- hs.alert.show("🔌 已接通电源")
    else
        hs.brightness.set(60)
        -- hs.alert.show("🔋 电池供电")
    end
    
    -- 更新全局状态记录
    hs.lastPowerStatus = currentStatus
end

-- 3. 创建监听器
hs.powerWatcher = hs.battery.watcher.new(function()
    local currentStatus = hs.battery.powerSource()
    
    -- 只有当状态真正改变时才执行，防止系统重复触发同一状态的回调
    if currentStatus ~= hs.lastPowerStatus then
        updateBrightness()
    end
end)

-- 4. 启动监听
hs.powerWatcher:start()

-- 5. 【关键】启动时立即执行一次，确保当前状态即刻生效
updateBrightness()

-- 定义切换桌面的函数
local function gotoSpace(num)
    -- 注意：这里模拟的是 macOS 默认的 Control + 数字键
    -- 如果你在系统设置中修改过切换桌面的快捷键，请相应修改此处的修饰键
    hs.eventtap.keyStroke({"ctrl"}, tostring(num))
    --hs.alert.show("🚀 桌面 " .. num, 0.5)
end

for i = 1, 9 do
    hs.hotkey.bind(hyper, tostring(i), function()
        gotoSpace(i)
    end)
end