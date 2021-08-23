local serial = require("serialization")
local component = require("component")
local thread = require("thread")
local event = require("event")
local term = require("term")
--local tunnel = component.tunnel
local data = component.data
local gpu = component.gpu

local tabletGui = {}

--[[snapshot = {
        ["time"] = os.date().."_"..os.time(),
        ["isProcessing"] = reactorMain.checkState(),
        ["heatLevel"] = reactorMain.checkHeatLevel(),
        ["heatMax"] = reactorMain.checkMaxHeatLevel(),
        ["heatCurrent"] = reactorMain.currentHeatLevel(),
        ["heatOutput"] = reactorMain.heatOutput(),
        ["energyLevel"] = reactorMain.checkEnergyLevel(),
        ["energyMax"] = reactorMain.checkMaxEnergyLevel(),
        ["energyStored"] = reactorMain.currentStoredPower(),
        ["energyChange"] = reactorMain.checkEnergyChange(),
        ["energyOutput"] = reactorMain.powerOutput(),
        ["fuelName"] = reactorMain.fuelName(),
        ["fuelRemainingTime"] = reactorMain.remainingProcessTime(),
        ["fuelEfficiency"] = reactorMain.efficiency()
}]]-- --this is an example of the data structure of each and every snapshot

    tabletGui["colorData"] = {
	    ["white"] = 0xF0F0F0,
	    ["orange"] = 0xF2B233,
	    ["magenta"] = 0xE57FD8,
	    ["lightBlue"] = 0x99B2F2,
	    ["yellow"] = 0xDEDE6C,
	    ["lime"] = 0x7FCC19,
	    ["pink"] = 0xF2B2CC,
	    ["gray"] = 0x4C4C4C,
	    ["lightGray"] = 0x999999,
	    ["cyan"] = 0x4C99B2,
	    ["purple"] = 0xB266E5,
	    ["blue"] = 0x3366CC,
	    ["brown"] = 0x7F664C,
	    ["green"] = 0x57A64E,
	    ["red"] = 0xCC4C4C,
	    ["black"] = 0,
    }--This is mostly for reference but is used by the function tabletGui.drawFrame()

--[[ Networking and Data retrieval ]]--

function tabletGui.checkMessages(timer)
    local eventType, thisserver, sender, port, distance, argA, argB, argC, argD, argE, argF, argG, argH = event.pull(timer+15, "modem_message")
    local messageData = { ["Time"] = os.time(), ["Sender"] = sender, ["Port"] = port, ["Distance"] =  distance, ["Argument1"] = argA, ["Argument2"] = argB, ["Argument3"] = argC, ["Argument4"] = argD, ["Argument5"] = argE, ["Argument6"] = argF, ["Argument7"] = argG, ["Argument8"] = argH }
	if (messageData.Sender == nil) and (messageData.Argument1 == nil) then
		return false
	else
		return true, messageData
	end
end --end checkMessages

function tabletGui.tunnelRequestSnapshot()
    tunnel.send(tunnel.getChannel(), "requestSnapshot")
    local recieved, messageData = tabletGui.checkMessages(0)
    if (recieved) then
        if (messageData.Argument1 == tunnel.getChannel()) and (messageData.Argument2 == "snapshot")then
            local snapshot = serial.unserialize(data.inflate(messageData.Argument3))
            return true, snapshot
        elseif (messageData.Argument2 == "No history available.") then
            return false, messageData.Argumetn2
        end
    else
        return false, "No messages recieved."
    end
end --end tunnelRequestSnapshot

function tabletGui.tunnelRequestHistory(count)
    tunnel.send(tunnel.getChannel(), "requestHistory", count)
    local recieved, messageData = tableGui.checkMessages(count)
    if (recieved) then
        if (messageData.Agrument1 == tunnel.getChannel()) and (messageData.Argument2 == "history") then
            local reactorHistory = serial.unserialize(data.inflate(messageData.Argument3))
            return true, reactorHistory
        elseif (messageData.Argument2 == "No history available.") then
            return false, messageData.Argumetn2
        end
    else
        return false, "No messages recieved."
    end
end --end tunnelRequestHistory

--[[ Graphics ]]--

function tabletGui.setupResolution() --Sets the resolution to the maximum supported
    local maxX, maxY = gpu.maxResolution()
    local currentX, currentY = gpu.getResolution()
    if (currentX ~= maxX) or (currentY ~= maxY) then
        if (gpu.setResolution(maxX, maxY)) then
            tabletGui.printToConsole("Resolution set to "..maxX.."x"..maxY)
            return true
        else
            tabletGui.printToConsole("The was an error in setting the resolution to it's max resolution.")
            tabletGui.printToConsole("The current resolution is "..currentX.."x"..currentY)
            return false
        end
    else
        tabletGui.printToConsole("The max and current resolution is "..currentX.."x"..currentY)
        return true
    end
end --end setupResolution

function tabletGui.gpuSet(x, y, string, boolean) 
    return gpu.set(x, y, string, boolean)
end --end gpuSet

function tabletGui.gpuCopy(x, y, width, height, tx, ty) 
    return gpu.copy(x, y, width, height, tx, ty)
end --end gpuCopy

function tabletGui.gpuFill(x, y, width, height, string)
    return gpu.fill(x, y, width, height, string)
end --end gpuFill

function tabletGui.gpuSetBackground(color) 
    return gpu.setBackground(color)
end --end gpuSetBackground

function tabletGui.gpuSetForeground(color) 
    return gpu.setForeground(color)
end --end gpuSetForeground

function tabletGui.printToConsole(printThis)
    local currentX, currentY = gpu.getResolution()
    term.setCursor(1, currentY)
    term.write(printThis, true)
    --print(printThis)
end --end printToConsole

function tabletGui.drawFrame()
    local currentX, currentY = gpu.getResolution()

    tabletGui.gpuSetBackground(tabletGui.colorData.black)
    tabletGui.gpuFill(1, 1, currentX, 1, " ")    --Top black bar
    tabletGui.gpuFill(1, 1, 1, currentY*4/5+1, " ")    --Left black bar
    tabletGui.gpuFill(currentX, 1, 1, currentY*4/5+1, " ")    --Right black bar
    tabletGui.gpuFill(1, currentY*4/5+2, currentX, 1, " ")    --Bottom black bar
    tabletGui.gpuFill(currentX-4, 2, 1, (currentY*4/5), " ")    --Vertical Power black bar
    tabletGui.gpuFill(currentX-8, 2, 1, (currentY*4/5), " ")    --Vertical Heat black bar

    tabletGui.gpuSetBackground(tabletGui.colorData.gray)
    tabletGui.gpuFill(2, 2, (currentX*7/8), (currentY*4/5), " ")    --Large Info Box
    tabletGui.gpuFill(currentX-3, 2, 3, (currentY*4/5), " ")    --Vertical Power Background
    tabletGui.gpuFill(currentX-7, 2, 3, (currentY*4/5), " ")    --Vertical Heat Background

    --Drawing Power/Heat Bars
    tabletGui.gpuSetBackground(tabletGui.colorData.gray)
    tabletGui.gpuSet(currentX-3, currentY*2/5, "POWER", true)
    tabletGui.gpuSetBackground(tabletGui.colorData.red)
    tabletGui.gpuFill(currentX-2, 3, 1, (currentY*4/5-2), " ")  --Red Power Level Bar
    tabletGui.gpuSetBackground(tabletGui.colorData.gray)
    tabletGui.gpuSet(currentX-7, currentY*2/5, "HEAT", true)
    tabletGui.gpuSetBackground(tabletGui.colorData.yellow)
    tabletGui.gpuFill(currentX-6, 3, 1, (currentY*4/5)-2, " ")  --Yellow Heat Level Bar
    
    tabletGui.gpuSetBackground(tabletGui.colorData.black)
    term.setCursor(1, currentY)
end

--[[ Process Management ]]--

function tabletGui.mainProcess()
    if (tabletGui.setupResolution()) then
        local t1 = thread.create(function() --Subroutines Process
        while true do
            tabletGui.printToConsole("...")
        end
        end)
        local t2 = thread.create(function() --GUI Drawing Process
        while true do
            tabletGui.printToConsole("Drawing...")
        end
        end)
    else
        printToConsole("There was an error when trying to setup the resolution.")
        return false
    end
    
    return false
end --end mainProcess

function tabletGui.main()
    while (true) do
        if (tabletGui.mainProcess()) then
            tabletGui.mainProcess()
        else
            tabletGui.mainProcess()
        end
    end
end --end main

--MOVE THE CODE BELOW TO ANOTHER FILE--
--[[
function tabletGui.readComponents()
    return computer.getDeviceInfo()
end --end readComponents

function tabletGui.getNetworkingComponents() --returns a table of all the networking components installed on the computer.
    local systemSpecs = tabletGui.readComponents()
    local networkSpecs = {}
    for i, k in pairs(systemSpecs) do
        for e, l in pairs(k) do
            if (e == "class") and (l == "network") then
                if (k.description == "Quantumnet controller") then
                    neworkSpecs[tostring(i)] = k
                elseif (k.description == "Wireless ethernet controller") then
                    neworkSpecs[tostring(i)] = k
                elseif (k.description == "Ethernet controller") then
                    neworkSpecs[tostring(i)] = k
                elseif (k.description == "Data processor card") then
                    neworkSpecs[tostring(i)] = k
                end
            end
        end
    end
    return networkSpecs
end --end getNetworkingComponents

function tabletGui.pollReactor(text, time)
    if (time == nil) then
        time = 0
    end
    if (text == nil) then
        print("Please try a valid command.")
    elseif (text == "requestSnapshot") then
        tunnel.send(component.tunnel.getChannel(), tostring(text), tostring(time))
        local question, messageData = tabletGui.checkMessages(time)
        if (question) and (messageData.Argument1 == tunnel.getChannel()) then
        print(messageData.Argument2)
        tabletGui["reactorSnapshot"] = serial.unserialize(messageData.Argument3)
    elseif (text == "requestHistory") then
        tunnel.send(component.tunnel.getChannel(), tostring(text), tostring(time))
        local question, messageData = tabletGui.checkMessages(time)
        if (question) and (messageData.Argument1 == tunnel.getChannel()) then
        print(messageData.Argument2)
        tabletGui["reactorHistory"] = serial.unserialize(messageData.Argument3))
    else
        print("Recieved and unauthorized message from:", messageData.Sender)
    end

    if (tabletGui.reactorSnapshot ~= nil) then
        print(tabletGui.reactorSnapshot.time, tabletGui.reactorSnapshot.energyLevel, tabletGui.reactorSnapshot.heatLevel)
    elseif (tabletGui.reactorHistory ~= nil) then
        for i, k in pairs(tabletGui.reactorHistory) do
            print(k.time, k.energyLevel, k.heatLevel)
        end
    end
end --end pollReactor
]]--

return tabletGui