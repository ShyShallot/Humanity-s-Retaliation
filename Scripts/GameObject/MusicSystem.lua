require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")
require("PGBase")

function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);
end

function State_Init(message)
    if message == OnEnter then
        DebugMessage("%s -- In OnEnter", tostring(Script))
        player = Object.Get_Owner()
        Create_Thread("Music_Handler", player, ServiceRate)
    end
    if message == OnUpdate then
    end
end

function Music_Handler()
    is_song_playing = false
    is_combat_song = false
    while true do
        if is_song_playing == false then
            DebugMessage("%s -- In OnUpdate", tostring(Script))
            song, length = Music_To_Play(false)
            DebugMessage("Song to Play: %s", tostring(song))
            DebugMessage("Length of the Song: %s", tostring(length))
            Play_Song(song, length)
            DebugMessage("%s -- Playing Song", tostring(Script))
            
        end
        if Is_Player_In_Combat(player) then
            if is_combat_song == false then
                DebugMessage("%s -- Player in Combat Overriding", tostring(Script))
                Combat_Music_Override()
            end
        end
        DebugMessage("%s -- Song Status", tostring(is_song_playing))
        DebugMessage("%s -- Combat Song Status", tostring(is_combat_song))
        Sleep(ServiceRate)
    end
end


function Init_Music_List()
    DebugMessage("%s -- Creating Song List", tostring(Script))
    idle_list = { -- Idle Music | ["Music Event Name"] = song length in seconds
            ["Idle_Black_Tower"] = 363,
            ["Idle_Edge"] = 184,
            ["Idle_Honrable"] = 166,
            ["Idle_Luck"] = 205,
            ["Idle_Reborn"] = 239,
            ["Idle_Released"] = 320,
            ["Idle_Roll_Call"] = 358,
            ["Idle_Steal"] = 156,
            ["Idle_Tribute"] = 172,
    }
    battle_list = { -- Battle Music
            ["Battle_Final_Effort"] = 188,
            ["Battle_Final_Effort_8_Bit"] = 180,
            ["Battle_Final_Effort_Remix"] = 183,
            ["Battle_Finish_Fight"] = 148,
            ["Battle_Grave_Mind"] = 322,
            ["Battle_Infiltrate"] = 230,
            ["Battle_Intrusion"] = 326,
            ["Battle_Journey"] = 292,
            ["Battle_Kill_A_Demon"] = 244,
            ["Battle_Pale_Horse"] = 338,
            ["Battle_The_Brave"] = 238,
            ["Battle_The_Hour"] = 129,
            ["Battle_Three_Gates"] = 274
    }
    DebugMessage("%s -- Song List Done", tostring(Script))
    return idle_list, battle_list
end

function Music_To_Play(override)
    idle_music, battle_music = Init_Music_List()
    player = Object.Get_Owner()
    DebugMessage("%s -- Player", tostring(player.Get_Name()))
    if Is_Player_In_Combat(player) or override == true then
        songs = battle_music -- Battle Music
        DebugMessage("%s -- Player in Combat, setting Combat List", tostring(Script))
    else
        DebugMessage("%s -- Player is not in combat, setting Idle List", tostring(Script))
        songs = idle_music -- Idle Music
    end
    song_list_length = table_length(songs)
    DebugMessage("%s -- Song List Length", tostring(song_list_length))
    random_song = GameRandom(1, song_list_length)
    DebugMessage("%s -- Song Index to Play", tostring(random_song))
    index = 1
    for song, length in pairs(songs) do
        DebugMessage("%s -- Current Index: %s", tostring(Script), tostring(index))
        if random_song == index then
            DebugMessage("%s -- Random Song Index is equal to current index", tostring(Script))
            stp = song
            slength = length
            DebugMessage("%s -- Song to Play: %s", tostring(Script), tostring(stp))
            DebugMessage("%s -- Length of the Song: %s", tostring(Script), tostring(slength))
            break
        else
            index = index + 1
            DebugMessage("%s -- Current Song List Index", tostring(Script), tostring(index))
        end
    end  
    return stp, slength
end

function Play_Song(song, length)
    DebugMessage("%s -- Running Play_Song Function", tostring(Script))
    Stop_All_Music()
    DebugMessage("%s -- Stopping All Music", tostring(Script))
    Play_Music(tostring(song))
    is_song_playing = true
    DebugMessage("%s -- Playing Song: %s", tostring(Script), tostring(song))
    Register_Timer(Song_Done, length)
end

function Is_Player_In_Combat(player)
    targets_in_range = 0
    friendly_unit_list = Find_All_Objects_Of_Type(player)
    enemy = Enemy_Player(player)
    enemy_unit_list = Find_All_Objects_Of_Type(enemy)
    for k, unit in friendly_unit_list do 
        if TestValid(unit) then
            target = Find_Nearest(unit, player, false)
            if TestValid(target) then
                if unit.Get_Distance(target) <= 4000 then
                    targets_in_range = targets_in_range + 1
                end
            end
        end
    end
    if targets_in_range >= 1 then
        return true
    end
end

function Combat_Music_Override()
    DebugMessage("%s -- Player is in combat overriding", tostring(Script))
    Stop_All_Music()
    if is_song_playing == true and is_combat_song == false then
        Cancel_Timer(Song_Done)
    end
    song, length = Music_To_Play(true)
    Play_Music(tostring(song))
    is_song_playing = true
    is_combat_song = true
    Register_Timer(Song_Done, length)
    DebugMessage("%s -- Override Complete", tostring(Script))
end

function Song_Done()
    is_song_playing = false
    Cancel_Timer(Song_Done)
    DebugMessage("%s -- Song Done Playing", tostring(Script))
end