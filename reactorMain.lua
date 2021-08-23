--[[
	Developed by Anthony Castillo (Cao21745) 6/6/2021
	Designed and tested for use with Minecraft version 1.12.2, OpenComputers-MC1.12.2-1.7.5.192.jar, and NuclearCraft-2.17c-1.12.2.jar.
	This is still a work in progress so any suggestions will be taken into consideration.
	Email suggesttions to Cao21745@yahoo.com
	This script will activate and deactivate a NuclearCraft reactor based on it's heat and energy levels.
	This will work independently of the GUI script. Simply make a call to the function reactorMain.main() and it will automate the activation process.
]]--

local filesystem = require("filesystem")
local serial = require("serialization")
local component = require("component")
local thread = require("thread")
local event = require("event")
local term = require("term")
local reactor = component.nc_fission_reactor
local data = component.data
local tunnel = component.tunnel
local gpu = component.gpu

local reactorMain = {}
local t1, t2, t3, t4

    reactorMain["colorData"] = {
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
    }--This is mostly just for reference

function reactorMain.checkState() end
--Will return true if the reactor is processing(on) or false if it is not processing(off)
--This function returns a boolean value (true or false)

function reactorMain.checkEnergyLevel() end
--Will return the current energy level of the reactor
--This function returns a double (0.0100000)

function reactorMain.checkHeatLevel() end
--Will return the current heat level of the reactor
--This function returns a double (0.0100000)

function reactorMain.checkMaxEnergyLevel() end
--Will return the max energy level of reactor

function reactorMain.checkMaxHeatLevel() end
--Will return the maximum heat level of the reactor

function reactorMain.checkEnergyChange() end
--Returns the power change

function reactorMain.heatOutput() end
--Returns the reactor's heat output in negative or positive

function reactorMain.powerOutput() end
--Returns the power output of the reactor

function reactorMain.currentStoredPower() end
--Returns the currently stored power

function reactorMain.currentHeatLevel() end
--Returns the current heat level

function reactorMain.fuelName() end
--Returns the name of the current fuel being processed

function reactorMain.remainingProcessTime() end
--Returns the remaining processing time for the current fuel type

function reactorMain.efficiency() end
--Returns the efficiency of the current reactor setup

function reactorMain.changeReactorState() end
--Will switch the reactor's active state

function reactorMain.checkMessages() end
--Will return any messages detected after a 15 second waiting period.	

function reactorMain.generateSnapshot() end
--creates and returns a snapshot of the reactor's core statistics

function reactorMain.grabHistoryReport(quantity) end
--returns the newest #quantity of snapshots from the main directory

function reactorMain.writeToFile(location, data) end
--attemps to write the data to the requested exact location

function reactorMain.logStats() end
--Returns a shapshot of the current reactor's status

function reactorMain.auto() end
--Will automate the reactor temperature and energy level monitoring

function reactorMain.commsService() end
--Manages inbound messages and outbout messages

function reactorMain.textUi() end
--Will run the automation processes except that it will also display a very primitive UI

function reactorMain.mainProcess() end
--Manages the core services of the program

function reactorMain.main() end
--This function should only be called if you do not want the primary GUI system.

function reactorMain.checkState()
	return reactor.isProcessing()
end --end checkState

function reactorMain.checkEnergyLevel()
	return reactor.getEnergyStored() / reactor.getMaxEnergyStored()
end --end checkEnergyLevel

function reactorMain.checkHeatLevel()
	return reactor.getHeatLevel() / reactor.getMaxHeatLevel()
end --end cheackHeatLevel

function reactorMain.checkMaxEnergyLevel()
	return reactor.getMaxEnergyStored()
end --end checkMaxEnergyLevel

function reactorMain.checkMaxHeatLevel()
	return reactor.getMaxHeatLevel()
end --end checkMaxHeatLevel

function reactorMain.checkEnergyChange() 
	return reactor.getEnergyChange()
end --end checkEnergyChange

function reactorMain.heatOutput()
	return reactor.getReactorProcessHeat()
end --end heatOutput

function reactorMain.powerOutput() 
	return reactor.getReactorProcessPower()
end --end powerOutput

function reactorMain.currentStoredPower()
	return reactor.getEnergyStored()
end --end currentStoredPower

function reactorMain.currentHeatLevel()
	return reactor.getHeatLevel()
end --end currentHeatLevel

function reactorMain.fuelName()
	return reactor.getFissionFuelName()
end --end fuelName

function reactorMain.remainingProcessTime() 
	return (reactor.getFissionFuelTime() - reactor.getCurrentProcessTime())
end --end remainingProcessTime

function reactorMain.efficiency() 
	return reactor.getEfficiency()
end --end efficiency

function reactorMain.changeReactorState()
	if reactorMain.checkState() then
		reactor.deactivate()
	else
		reactor.activate()
	end
end --end changeReactorState

function reactorMain.checkMessages()
    local eventType, thisserver, sender, port, distance, argA, argB, argC, argD, argE, argF, argG, argH = event.pull(5, "modem_message")
    local messageData = { ["Time"] = os.time(), ["Sender"] = sender, ["Port"] = port, ["Distance"] =  distance, ["Argument1"] = argA, ["Argument2"] = argB, ["Argument3"] = argC, ["Argument4"] = argD, ["Argument5"] = argE, ["Argument6"] = argF, ["Argument7"] = argG, ["Argument8"] = argH }
	if (messageData.Sender == nil) and (messageData.Argument1 ==nil) then
		return false
	else
		return true, messageData
	end
end --end checkMessages

function reactorMain.generateSnapshot()
    local snapshot = {
        ["Timestamp"] = os.date().."_"..os.time(),
        ["Active"] = reactorMain.checkState(),
        ["Heat Level"] = reactorMain.checkHeatLevel(),
        ["Max Heat"] = reactorMain.checkMaxHeatLevel(),
        ["Current Heat"] = reactorMain.currentHeatLevel(),
        ["Heat Output"] = reactorMain.heatOutput(),
        ["Energy Level"] = reactorMain.checkEnergyLevel(),
        ["Max Energy"] = reactorMain.checkMaxEnergyLevel(),
        ["Stored Energy"] = reactorMain.currentStoredPower(),
        ["Energy Rate of Change"] = reactorMain.checkEnergyChange(),
        ["Energy Output"] = reactorMain.powerOutput(),
        ["Fuel Name"] = reactorMain.fuelName(),
        ["Fuel's Remainging Burn Time"] = reactorMain.remainingProcessTime(),
        ["Fuel Efficiency"] = reactorMain.efficiency()
    }
    return snapshot
end --end generateSnapshot

function reactorMain.grabLatestSnapshot()
    local historyReport = { ["reportDate"] = tostring(os.date().."_"..os.time()) }
    local baseLocation = "/home/reactorHistory/"
    if (filesystem.isDirectory(baseLocation)) then
        local latestSnapshot, newestFile, inData, tempData = nil, nil, nil, nil
        local fileList = {}
        local count = 0
        local files = filesystem.list(baseLocation)
        local file, errorMessage = files()
        while (file ~= nil) do --We want to gather a list of all the files before a new one gets added
            if (errorMessage == nil) then
                fileList[count] = file
                count = count + 1
            else
                print("filessystem.list() error message: "..errorMessage)
            end
            errorMessage = nil
            file, errorMessage = files()
        end
        fileList["fileCount"] = count
        --os.sleep(0)
        for i, k in pairs(fileList) do --Here we'll begin parsing the files and looking for the latest one
            if (i ~= "fileCount") and (k ~= nil) then
                if (newestFile == nil) then
                    newestFile = k
                elseif (filesystem.lastModified(baseLocation..k) > filesystem.lastModified(baseLocation..newestFile)) then
                    print(k.." is newer than "..newestFile)
                    newestFile = k
                else
                    --os.sleep(0)
                end
            else
                --os.sleep(0)
            end
        end
        inData = io.open(baseLocation..newestFile) --Now we read the newest file
        tempData = inData:read("*a")
        inData:close()
        if (tempData == nil) then   --We'll delete the file if no data was read from it
            filesystem.remove(baseLocation..newestFile)
            return reactorMain.grabLatestSnapshot() --Since we deleted the "newest file" we need to fetch a new one
        else
            table.insert(historyReport, 1, serial.unserialize(tempData))
            return historyReport, 1
        end
    else
        print("The directory "..baseLocation.." does not exist.")
        return nil, "No history available."
    end
    return reactorMain.grabLatestSnapshot()
end --end grabLatestSnapshot

function reactorMain.grabHistoryReport(quantity)
    local historyReport = { ["reportDate"] = tostring(os.date().."_"..os.time()) }
    local reportCount = 0
    local fileList = {}
    local baseLocation = "/home/reactorHistory/"
    if (filesystem.isDirectory(baseLocation)) then
        local files = filesystem.list(baseLocation)
        local count = 0
        while (count < tonumber(quantity)+1) do
            local location, errorMessage = files()
            if (location ~= nil) then
                fileList[count] = location
            else
                print(tostring(errorMessage))
            end
            count = count + 1
        end
        os.sleep(0)
        for i, k in pairs(fileList) do
            if (i ~= nil) and (k ~= nil) then
                --print(i, k)
                if (filesystem.exists(baseLocation..k)) then
                    print("Opening file:"..baseLocation..k)
                    local file = io.open(baseLocation..k)
                    local tempData = file:read("*a")
                    file:close()
                    if (tempData == nil) then
                        filesystem.remove(baseLocation..k)
                        print("Deleteing file: "..baseLocation..k)
                    else
                        table.insert(historyReport, 1, serial.unserialize(tempData))
                        reportCount = reportCount + 1
                    end
                end
            else
                print("No history report found at: "..baseLocation, tostring(k))
            end
            os.sleep(0)
        end
        historyReport["reportLength"] = reportCount
        return historyReport, historyReport.reportLength
    else
        return nil, "No history available."
    end
end --end grabHistoryReport

--[[ Graphics Functions Below ]]--

function reactorMain.setupResolution() --Sets the resolution to the maximum supported
    local maxX, maxY = gpu.maxResolution()
    local currentX, currentY = gpu.getResolution()
    if (currentX ~= maxX) or (currentY ~= maxY) then
        if (gpu.setResolution(maxX, maxY)) then
            reactorMain.print("Resolution set to "..maxX.."x"..maxY)
            return true
        else
            reactorMain.print("The was an error in setting the resolution to it's max resolution.")
            reactorMain.print("The current resolution is "..currentX.."x"..currentY)
            return false
        end
    else
        reactorMain.print("The current resolution is "..currentX.."x"..currentY)
        return true
    end
end --end setupResolution

function reactorMain.gpuSet(x, y, string, boolean) 
    return gpu.set(x, y, string, boolean)
end --end gpuSet

function reactorMain.gpuCopy(x, y, width, height, tx, ty) 
    return gpu.copy(x, y, width, height, tx, ty)
end --end gpuCopy

function reactorMain.gpuFill(x, y, width, height, string)
    return gpu.fill(x, y, width, height, string)
end --end gpuFill

function reactorMain.gpuSetBackground(color) 
    return gpu.setBackground(color)
end --end gpuSetBackground

function reactorMain.gpuSetForeground(color) 
    return gpu.setForeground(color)
end --end gpuSetForeground

function reactorMain.drawFrame()
    local currentX, currentY = gpu.getResolution()

    reactorMain.gpuSetBackground(reactorMain.colorData.black)
    reactorMain.gpuFill(1, 1, currentX, 1, " ")    --Top black bar
    reactorMain.gpuFill(1, 1, 1, currentY*4/5+1, " ")    --Left black bar
    reactorMain.gpuFill(currentX, 1, 1, currentY*4/5+1, " ")    --Right black bar
    reactorMain.gpuFill(1, currentY*4/5+2, currentX, 1, " ")    --Bottom black bar
    reactorMain.gpuFill(currentX-4, 2, 1, (currentY*4/5), " ")    --Vertical Power black bar
    reactorMain.gpuFill(currentX-8, 2, 1, (currentY*4/5), " ")    --Vertical Heat black bar
    reactorMain.gpuSetBackground(reactorMain.colorData.black)
    os.sleep(0)

    reactorMain.gpuSetBackground(reactorMain.colorData.gray)
    reactorMain.gpuFill(2, 2, (currentX*7/8), (currentY*4/5), " ")    --Large Info Box
    reactorMain.gpuFill(currentX-7, 2, 3, (currentY*4/5), " ")    --Vertical Heat Background
    reactorMain.gpuSet(currentX-7, currentY*2/5, "HEAT", true)
    reactorMain.gpuFill(currentX-3, 2, 3, (currentY*4/5), " ")    --Vertical Power Background
    reactorMain.gpuSet(currentX-3, currentY*2/5, "POWER", true)
    reactorMain.gpuSetBackground(reactorMain.colorData.black)
    os.sleep(0)
    
    reactorMain.gpuSetBackground(reactorMain.colorData.black)
    term.setCursor(1, currentY)
    os.sleep(0)
end

function reactorMain.drawInfo(snapshot)
    local currentX, currentY = gpu.getResolution()
    if (snapshot ~= false) then
        for i, k in pairs(snapshot) do 
            if (i == "reportDate") then
                --reactorMain.print("Report generated on: "..k)
                os.sleep(0)
            elseif (i == "reportLength") then
                --reactorMain.print("Length of Report: "..k)
                os.sleep(0)
            else
                local lineCount = 4 --Start off at two because we have a thin black box at the top of the screen and we want a thin grey outline around our UI
                for e, l in pairs(k) do
                    reactorMain.gpuSetBackground(reactorMain.colorData.gray)
                    if (e == "Timestamp") then
                        reactorMain.gpuSet(currentX/5, 2, "Reactor Snapshot: "..l, false)
                        os.sleep(0)
                    elseif (e == "Energy Level") then
                        reactorMain.gpuSetBackground(reactorMain.colorData.red)
                        reactorMain.gpuFill(currentX-2, 3, 1, l*(currentY*4/5-2), " ")  --Red Power Level Bar
                        reactorMain.gpuSetBackground(reactorMain.colorData.gray)
                    elseif (e == "Heat Level") then
                        reactorMain.gpuSetBackground(reactorMain.colorData.yellow)
                        reactorMain.gpuFill(currentX-6, 3, 1, l*(currentY*4/5)-2, " ")  --Yellow Heat Level Bar
                        reactorMain.gpuSetBackground(reactorMain.colorData.gray)
                    end

                    term.setCursor(3, lineCount)
                    term.write(e..": "..tostring(l))
                    lineCount = lineCount + 1
                    reactorMain.gpuSetBackground(reactorMain.colorData.black)
                    if (lineCount > currentY*4/5-1) then
                        break
                    end
                    os.sleep(0)
                end
                os.sleep(0)
            end
            os.sleep(15)
        end
        reactorMain.gpuSetBackground(reactorMain.colorData.black)
        term.setCursor(1, currentY)
        os.sleep(0)
    end
    os.sleep(0)
end

--[[ Non-graphics Below ]]--

function reactorMain.writeToFile(location, data) -- does not deflate, but does serialize
    local file, errorMessage = io.open(tostring(location), "w")
    if (file == nil) then
        print("Could not open file location: "..errorMessage)
    elseif (file ~= nil) then
        file:write(serial.serialize(data))
        file:write("\n")
        file:close()
    else
        file:write(serial.serialize(data))
        file:write("\n")
        file:close()
    end
    if (file ~= nil) then
        file:close()
    end
    os.sleep(0)
end --end writeToFile

function reactorMain.logStats()
    local count = 0
    local baseLocation = "/home/reactorHistory/"
    local prefix = ".log"
    if (filesystem.exists(tostring(baseLocation)) ~= true) then
        local bool, errorMessage = filesystem.makeDirectory(tostring(baseLocation))
        if (bool ~= true) then
            print("Could not setup logging directory:"..errorMessage)
        end
    end
    print("Saving all logs to:" .. baseLocation)
	while (true) do
        local location = tostring(baseLocation..os.time()..prefix)
        while (filesystem.exists(tostring(location)) == true) do
            location = tostring(baseLocation..os.time()..prefix)
        end
        reactorMain.writeToFile(location, reactorMain.generateSnapshot())
        --print("Snapshot generated: "..location)
        count = count + 1
        os.sleep(5)
    end
end --end logStats

function reactorMain.auto()
     (true) do
        if (reactorMain.checkState()) and ((reactorMain.checkMaxEnergyLevel() - reactorMain.currentStoredPower()) < reactorMain.powerOutput()*3) or ((reactorMain.checkMaxHeatLevel() - reactorMain.currentHeatLevel()) < reactorMain.heatOutput()*3) then
            reactorMain.changeReactorState() --turn off reactor
        elseif (reactorMain.checkState() == false) and (reactorMain.checkEnergyLevel() <= 0.20) and (reactorMain.checkHeatLevel() <= 0.20)then
            reactorMain.changeReactorState() --turn on reactor
        end
        os.sleep(0)
    end
    --[[
        while (true) do
        if (reactorMain.checkState()) and ((reactorMain.checkEnergyLevel() >= 0.80) or (reactorMain.checkHeatLevel() >= 0.80)) then
            reactorMain.changeReactorState() --turn off reactor
        elseif (reactorMain.checkState() == false) and (reactorMain.checkEnergyLevel() <= 0.20) and (reactorMain.checkHeatLevel() <= 0.20)then
            reactorMain.changeReactorState() --turn on reactor
        end
        os.sleep(0)
    end
    ]]
    while
end --end auto

function reactorMain.commsService()
    while (true) do
        local question, messageData = reactorMain.checkMessages() --will return true and the messageData if a message was recieved. Else, will return false
        local tempData = nil
        local historyCount = 0
        if (question) then
            if (messageData.Argument1 == tunnel.getChannel()) then
                if (messageData.Argument2 == "requestSnapshot") then
                    tempData, historyCount = reactorMain.grabLatestSnapshot()
                    if (tempData ~= nil) then
                        tunnel.send(tunnel.getChannel(), "snapshot", data.deflate(serial.serialize(tempData)))
                    else
                        tunnel.send(tunnel.getChannel(), "snapshot", hisotryCount)
                    end
                elseif (messageData.Argument2 == "requestHistory") then
                    if (messageData.Argument3 == nil) then
                        tempData, historyCount = reactorMain.grabHistoryReport(10)
                        if (tempData ~= nil) then
                            tunnel.send(tunnel.getChannel(), "history", data.deflate(serial.serialize(tempData)), historyCount)
                        else
                            tunnel.send(tunnel.getChannel(), "history", historyCount)
                        end
                    elseif (messageData.Argument3 ~= nil) and (tonumber(messageData.Argument3) > 0) and (tonumber(messageData.Argument3) <= 6000) then
                        if (tempData ~= nil) then
                            tunnel.send(tunnel.getChannel(), "history", data.deflate(serial.serialize(tempData)), historyCount)
                        else
                            tunnel.send(tunnel.getChannel(), "history", historyCount)
                        end
                    else
                        if (tempData ~= nil) then
                            tunnel.send(tunnel.getChannel(), "history", data.deflate(serial.serialize(tempData)), historyCount)
                        else
                            tunnel.send(tunnel.getChannel(), "history", historyCount)
                        end
                    end
                else
                    tunnel.send(tunnel.getChannel(), "Please send a command.", "Please send a command.")
                end
            else
                print("Unauthorized message from:", messgaedData.Sender)
            end
        else
            os.sleep(0)
        end
        os.sleep(0)
    end
end --end commsService

function reactorMain.textUi()
    while (true) do
        --local data, message = reactorMain.grabLatestSnapshot()
        local historyReport = { ["reportDate"] = tostring(os.date().."_"..os.time()) }
        table.insert(historyReport, 1, reactorMain.generateSnapshot())
        --local data = reactorMain.generateSnapshot()
        if (data ~= nil) then
            reactorMain.drawFrame()
            reactorMain.drawInfo(historyReport)
        else
            print("Could not retrieve latest snapshot.")
        end
        --data, message = nil, nil
        historyReport = nil
        os.sleep(0)
    end
end --end textUi

function reactorMain.setupResolution() --Sets the resolution to the maximum supported
    local maxX, maxY = gpu.maxResolution()
    local currentX, currentY = gpu.getResolution()
    if (currentX ~= maxX) or (currentY ~= maxY) then
        if (gpu.setResolution(maxX, maxY)) then
            reactorMain.print("Resolution set to "..maxX.."x"..maxY)
            return true
        else
            reactorMain.print("The was an error in setting the resolution to it's max resolution.")
            reactorMain.print("The current resolution is "..currentX.."x"..currentY)
            return false
        end
    else
        reactorMain.print("The current resolution is "..currentX.."x"..currentY)
        return true
    end
end --end setupResolution

function reactorMain.mainProcess()
    --initialize services
    t2 = thread.create(function()
        while true do
            reactorMain.logStats()
            os.sleep(0)
            thread.current:suspend()
        end
    end)
    t3 = thread.create(function()
        while true do
            reactorMain.commsService()
            os.sleep(0)
            thread.current:suspend()
        end
    end)
    t4 = thread.create(function()
        while true do
            reactorMain.textUi()
            os.sleep(0)
            thread.current:suspend()
        end
    end)
    t1 = thread.create(function()
        while true do
            reactorMain.auto()
            os.sleep(0)
            thread.current:suspend()
        end
    end)
    local temp = 0
	while (true) do
        local startTime = os.time()
        --print("Cycle#: "..temp)
        --print("Monitoring Service: "..t1:status())
		--print("Statistics Logging Service: "..t2:status())
		--print("Communications Service: "..t3:status())
		--print("SimpleUi Service: "..t4:status())
		if (t1:status() == "suspended") or (t1:status() == "normal") then
            thread.resume(t1)
        elseif (t2:status() == "suspended") or (t2:status() == "normal") then
            thread.resume(t2)
        elseif (t3:status() == "suspended") or (t3:status() == "normal") then
            thread.resume(t3)
        elseif (t4:status() == "suspended") or (t4:status() == "normal") then
            thread.resume(t4)
        elseif (t1:status() == "dead") and (t2:status() == "dead") and (t3:status() == "dead") and (t4:status() == "suspended") then
            print("All threads have died. Restarting program.")
            return false
        elseif (t1:status() == "dead") then
            print("The main monitoring thread has died! Restarting the program.")
            t2:kill()
            t3:kill()
            t4:kill()
            os.sleep(5)
            t1 = nil
            t2 = nil
            t3 = nil
            t4 = nil
            return false
        end
        if (t2:status() == "dead") then print("The logging statistics thread has died!") end
        if (t3:status() == "dead") then print("The communications service thread has died!") end
        if (t4:status() == "dead") then print("The SimpleUi thread has died!") end
        os.sleep(0)
        temp = temp + 1
        --print()
	end
    return true
end --end mainProcess

function reactorMain.main()
    while (true) do
        if (reactorMain.mainProcess()) then
            reactorMain.mainProcess()
        else
            reactorMain.mainProcess()
        end
        os.sleep(0)
    end
end --end main

return reactorMain