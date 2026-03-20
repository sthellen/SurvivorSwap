// =========================================================================
// Survivor Swap
// Version: 2026.03.15_2118
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE./
//
// MIT No Attribution (MIT-0)
// Copyright © 2026 St. Hellen
// =========================================================================

::SurvSwap <-
{
  ConLog = function(text)
  {
    printl("[SURVSWAP][INFO] " + text);
  }

  Survivors =
  {
    nick      =    { Model = "models/survivors/survivor_gambler.mdl",   Index = [ 0, 0 ], Name = "Nick",     Context = "Gambler"  }
    rochelle  =    { Model = "models/survivors/survivor_producer.mdl",  Index = [ 1, 1 ], Name = "Rochelle", Context = "Producer" }
    coach     =    { Model = "models/survivors/survivor_coach.mdl",     Index = [ 2, 2 ], Name = "Coach",    Context = "Coach"    }
    ellis     =    { Model = "models/survivors/survivor_mechanic.mdl",  Index = [ 3, 3 ], Name = "Ellis",    Context = "Mechanic" }
    bill      =    { Model = "models/survivors/survivor_namvet.mdl",    Index = [ 4, 0 ], Name = "Bill",     Context = "NamVet"   }
    zoey      =    { Model = "models/survivors/survivor_teenangst.mdl", Index = [ 5, 1 ], Name = "Zoey",     Context = "TeenGirl" }
    francis   =    { Model = "models/survivors/survivor_biker.mdl",     Index = [ 6, 3 ], Name = "Francis",  Context = "Biker"    }
    louis     =    { Model = "models/survivors/survivor_manager.mdl",   Index = [ 7, 2 ], Name = "Louis",    Context = "Manager"  }
  }

  LightModels =
  {
    FrancisLight = { Model = "models/survivors/survivor_biker_light.mdl",     Name = "FrancisLight" }
    ZoeyLight    = { Model = "models/survivors/survivor_teenangst_light.mdl", Name = "ZoeyLight"    }
  }
}

SurvSwap.Func <-
{
  Survivors = SurvSwap.Survivors
  LightModels = SurvSwap.LightModels

  // Empty table to temporarily store a single network ID and check for bots.
  // This is for edge cases where bots are considered human.
  // Used in isBot() func.
  // TODO: Create an network ID array that stores the ID of every player
  PlayerNetID = {}

  OnGameEvent_player_first_spawn = function(params)
  {
    local Player = GetPlayerFromUserID(params.userid);
    local CurrentModel = Player.GetModelName();
    if (Player == null || CurrentModel == null) return;

    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_bot_player_replace = function(params)
  {
    local Player = GetPlayerFromUserID(params.player);
    local CurrentModel = Player.GetModelName();
    if (Player == null || CurrentModel == null) return;

    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_player_say = function(params)
  {
    local Player = GetPlayerFromUserID(params.userid);
    local UserInput = params.text.tolower();
    PlayerNetID[0] <- Player.GetNetworkIDString();
    if (Player == null || !Player.IsSurvivor() || IsBot() || UserInput[0] != '!') return;

    Token = strip(UserInput.slice(1)).split(UserInput, " ");
    local Character = Token[0];
    local SayTarget = null;

    if (Token.len() == 2 && Token[1] != null)
    {
      SayTarget = Token[1];
    }

    if (SayTarget != null && SayTarget in Survivors)
    {
      SayTarget = FindSayTarget(SayTarget, Player);
      SwapSurvivor(SayTarget, Character);
    }
    if (Character in Survivors)
    {
      SwapSurvivor(Player, Character);
    }
  }

  FindSayTarget = function(SayTarget, Issuer)
  {
    PlayerNetID[0] <- SayTarget.GetNetworkIDString();
    if (!IsBot())
    {
      ClientPrint(Issuer, 5, "Only bots can be targets!");
      SurvSwap.ConLog("Swap failed: Only bots can be targets!");
      return;
    }
    SayTarget = Survivors[SayTarget];
    local SurvSet = Director.GetSurvivorSet();
    SayTarget = GetPlayerFromCharacter(SayTarget.Index[SurvSet == 1 ? 1 : 0]);
    return SayTarget;
  }

  SwapSurvivor = function(Player, Character)
  {
    Character = Survivors[Character];
    Player.SetModel(Character.Model);

    local SurvSet = Director.GetSurvivorSet();
    SayTarget = GetPlayerFromCharacter(SayTarget.Index[SurvSet == 1 ? 1 : 0]);

    Player.SetContext("who", Character.Context, -1);
    local PlayerName = Player.GetPlayerName();
    SurvSwap.ConLog(PlayerName + "'s character was swapped to " + Character.Name + "!");

    if (IsBot())
    {
      SetFakeClientConVarValue(Player, "name", Character.Name);
    }
  }

  SetSurvivorContext = function(Player, CurrentModel)
  {
    // TODO: Convert to a map
    foreach (Name, Value in Survivors)
    {
      if (Value.Model == CurrentModel)
      {
        Player.SetContext("who", Value.Context, -1);
        local PlayerName = Player.GetPlayerName();
        if (PlayerName != Value.Name)
          SurvSwap.ConLog(PlayerName + "'s context was automatically set to " + Value.Name + "!");
        return;
      }
    }
  }

  IsBot = function()
  {
    PlayerNetID[0] == "BOT" ?  return NetID : return null;
  }

  CheckPrecache = function()
  {
    local ModelSet = [Survivors, LightModels];
    SurvSwap.ConLog("Checking for missing survivor models in precache...");
    // TODO: Attempt to convert into a map
    for (local i = 0; i < ModelSet.len(); i++)
    {
      foreach (Name, Value in ModelSet[i])
      {
        if (!IsModelPrecached(Value.Model))
        {
          SurvSwap.ConLog(Value.Name + " is not precached! Caching...");
          PrecacheModel(Value.Model);
        }
      }
    }
    Initialized();
  }

  Initialized = function()
  {
    SurvSwap.ConLog("Survivor Swap has been initialized.");
  }
}

SurvSwap.Func.CheckPrecache();

__CollectEventCallbacks(SurvSwap.Func, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
