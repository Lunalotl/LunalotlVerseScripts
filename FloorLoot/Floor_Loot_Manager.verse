using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }
using {/Verse.org/Concurrency}


<#
 ___       ___  ___  ________   ________  ___       ________  _________  ___          
|\  \     |\  \|\  \|\   ___  \|\   __  \|\  \     |\   __  \|\___   ___\\  \         
\ \  \    \ \  \\\  \ \  \\ \  \ \  \|\  \ \  \    \ \  \|\  \|___ \  \_\ \  \        
 \ \  \    \ \  \\\  \ \  \\ \  \ \   __  \ \  \    \ \  \\\  \   \ \  \ \ \  \       
  \ \  \____\ \  \\\  \ \  \\ \  \ \  \ \  \ \  \____\ \  \\\  \   \ \  \ \ \  \____  
   \ \_______\ \_______\ \__\\ \__\ \__\ \__\ \_______\ \_______\   \ \__\ \ \_______\
    \|_______|\|_______|\|__| \|__|\|__|\|__|\|_______|\|_______|    \|__|  \|_______|


>>> If you're using this script, all I ask is for proper credit! I'd prefer you just link my socials (Twitter/X, YouTube, etc.) :)

>>> Questions? Join my Discord and ask, I'll do my best to help out: https://discord.gg/2zJsUqj8Ex

#>


# tag for floor loot props, add to blueprint
FloorLootTag := class(tag){}    # tag that you'll add to the custom blueprint



Floor_Loot_Manager := class(creative_device):

    @editable
    TestingVariables : testing_variables = testing_variables{}    # ignore this :P

    @editable   FloorLootPlacer : item_spawner_device = item_spawner_device{}    # determines the item spawner device used
    @editable   TimeBetweenSpawns : float = 0.1    # time between each item spawn, leave at 0.1 (will take 10 seconds to spawn a full 100 items)
    @editable   SpawnChances : SpawnChance = SpawnChance.Common_Spawn   # sets variable for chosen spawn chance
    @editable   DoBasicPrintStatements : logic = true
    @editable   DoExtraPrintStatements : logic = false

    var SpawnedItems : int = 0      # total items spawned, leave at 0
    var FloorLoot : []creative_prop = array{}       # array for floor loot
    var ChosenSpawnChance : int = 2    # spawn chance baseed on chosen option, variable value is set below (the big else if block)


    # spawns the floor loot when called
    SpawnFloorLoot()<suspends>:void=


        SpawnLocations := GetCreativeObjectsWithTag(FloorLootTag{})        # gets objects w/ tag at line 9
        Print("Total Spawn Locations: {SpawnLocations.Length}")        # prints total amount of spawn locations


        # else if block to determine spawn chance
        if (SpawnChances = SpawnChance.Common_Spawn): 
            set ChosenSpawnChance = 2
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 2, items will spawn 50% of the time.")
        else if (SpawnChances = SpawnChance.Uncommon_Spawn):
            set ChosenSpawnChance = 3
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 3, items will spawn 33% of the time.")
        else if (SpawnChances = SpawnChance.Rare_Spawn):
            set ChosenSpawnChance = 4
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 4, items will spawn 25% of the time.")
        else if (SpawnChances = SpawnChance.Super_Rare_Spawn):
            set ChosenSpawnChance = 5
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 5, items will spawn 20% of the time.")
        else if (SpawnChances = SpawnChance.Guaranteed_Spawn):
            set ChosenSpawnChance = 1
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 1, items will spawn 100% of the time.")
        else:
            set ChosenSpawnChance = 2
            if (DoBasicPrintStatements = true): 
                Print("Spawn Chance is 2, items will spawn 50% of the time.")

        
        
        ShuffledSpawns := Shuffle(SpawnLocations)   # shuffles spawn order



        # for each spawn location, add prop to array
        for (Index->Obj : ShuffledSpawns):   
            if (Prop := creative_prop[Obj]):    # if current spot in array is a creative prop, do the following

    
                SpawnPosition := vector3{X := Prop.GetTransform().Translation.X, Y := Prop.GetTransform().Translation.Y, Z := Prop.GetTransform().Translation.Z}     # get the transform of the next spawn location
                if (DoBasicPrintStatements = true): 
                    Print("Position: {SpawnPosition}")

                
                RandomSpawnItemChance : int = GetRandomInt(1, ChosenSpawnChance)    # determines if an item will spawn using the spawn chance set within the device settings
                if (DoBasicPrintStatements = true): 
                    Print("Spawn Chance = {RandomSpawnItemChance}")


                if (RandomSpawnItemChance = 1):
                    if(FloorLootPlacer.TeleportTo[SpawnPosition, FloorLootPlacer.GetTransform().Rotation]):     # teleport item spawner to next position
                        FloorLootPlacer.SpawnItem()     # if item spawner teleported, spawn item
                        if (DoExtraPrintStatements = true): 
                            Print("Teleported Prop")
                        set SpawnedItems += 1
                        Sleep(TimeBetweenSpawns)
                    else:
                        if (DoBasicPrintStatements = true): 
                            Print("Did not Teleport Prop")      # if prop was not teleported (somehow), print statement

                Prop.Dispose()

                set FloorLoot += array{Prop}    # go to next spot in the array
                if (DoExtraPrintStatements = true): 
                    Print("Success {Index}")

            else {Print("Failure")}     # if current spot in array is NOT a creative prop, print failure



    OnBegin<override>()<suspends>:void=   #activates on game start


        SpawnFloorLoot()    #calls the function to spawn floor loot


        loop:   # loop to fix a bug where the spawn item script gets run forever, don't really know a faster way around it and i'm too lazy to find a faster way :P
            

            if (SpawnedItems = 100):
                if (DoBasicPrintStatements = true): 
                    Print("Maximum Items Spawned, Breaking Loop.")
                break:
            else:
                if (DoExtraPrintStatements = true): 
                    #Print("Spawned Items: {SpawnedItems}") # THIS LINE WILL INFINITELY LOOP IF SPAWNED ITEMS DOES NOT EQUAL / EXCEED 100

                    
            Sleep(TimeBetweenSpawns)

    

<# 

                Old script for testing device, left in just in case

    MoveProp():void=

        Xposition := GetRandomFloat(TestPosition1.X, TestPosition2.X)
        Yposition := GetRandomFloat(TestPosition1.Y, TestPosition2.Y)
        Zposition := GetRandomFloat(TestPosition1.Z, TestPosition2.Z)
        
        PropPosition : vector3 = vector3{X := Xposition, Y := Yposition, Z := Zposition}

        loop:
            if(FloorLootPlacer.TeleportTo[PropPosition, FloorLootPlacer.GetTransform().Rotation]):
                FloorLootPlacer.SpawnItem()
                Print("Teleported Prop")
            else:
                Print("Did not Teleport Prop") 
            break:
#>


    


testing_variables := struct<concrete>:
    @editable   These_Variables_Do_Nothing : logic = true
    @editable   TestLocation : []creative_prop = array{}
    @editable   TestPosition1 : vector3 = vector3{}
    @editable   TestPosition2 : vector3 = vector3{}
    @editable   TestMoveTime : float = 0.5


SpawnChance := enum:
    Guaranteed_Spawn
    Common_Spawn
    Uncommon_Spawn
    Rare_Spawn
    Super_Rare_Spawn
