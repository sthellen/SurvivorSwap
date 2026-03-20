// =========================================================================
// Survivor Swap
// Version: 2026.03.15_2118
// Author: St. Hellen
//
// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// For more information, please refer to <https://unlicense.org>
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
  ID = {}

  OnGameEvent_player_first_spawn = function(params)
  {
    local Player = GetPlayerFromUserID(params.userid);
    local CurrentModel = Player.GetModelName();

    if (Player == null || CurrentModel == null)
      return;

    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_bot_player_replace = function(params)
  {
    local Player = GetPlayerFromUserID(params.player);
    local CurrentModel = Player.GetModelName();

    if (Player == null || CurrentModel == null)
      return;

    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_player_say = function(params)
  {
    local Player = GetPlayerFromUserID(params.userid);
    local Text = params.text.tolower();
    ID[0] <- Player.GetNetworkIDString();

    if (Player == null
    || !Player.IsSurvivor()
    || IsBot()
    || Text[0] != '!')
      return;

    Text = strip(Text.slice(1));
    Text = split(Text, " ");
    local TextLen = Text.len();
    local Character = Text[0];
    local SayTarget = null;

    if (TextLen == 2)
      if (Text[1] != null)
        SayTarget = Text[1];

    if (Character in Survivors)
    {
      if (TextLen < 2)
        SwapSurvivor(Player, Character);

      if ( (SayTarget in Survivors) && TextLen == 2 )
      {
        SayTarget = FindSayTarget(SayTarget, Player);
        if (SayTarget != null)
          SwapSurvivor(SayTarget, Character);
      }
    }
  }

  FindSayTarget = function(SayTarget, Issuer)
  {
    SayTarget = Survivors[SayTarget];
    local SurvSet = Director.GetSurvivorSet();
    if (SurvSet == 1)
      SayTarget = GetPlayerFromCharacter(SayTarget.Index[1]);
    else
      SayTarget = GetPlayerFromCharacter(SayTarget.Index[0]);

    ID[0] <- SayTarget.GetNetworkIDString();
    if (!IsBot())
      {
        ClientPrint(Issuer, 5, "Only bots can be targets!");
        SurvSwap.ConLog("Swap failed: Only bots can be targets!");
        return SayTarget = null;
      }
    return SayTarget;
  }

  SwapSurvivor = function(Player, Character)
  {
    Character = Survivors[Character];
    Player.SetModel(Character.Model);

    local SurvSet = Director.GetSurvivorSet();
    if (SurvSet == 1)
      NetProps.SetPropIntArray(Player, "m_survivorCharacter", Character.Index[1], 0);
    else
      NetProps.SetPropIntArray(Player, "m_survivorCharacter", Character.Index[0], 0);

    Player.SetContext("who", Character.Context, -1);
    local PlayerName = Player.GetPlayerName();
    SurvSwap.ConLog(PlayerName + "'s character was swapped to " + Character.Name + "!");

    if (IsBot())
      SetFakeClientConVarValue(Player, "name", Character.Name);
  }

  SetSurvivorContext = function(Player, CurrentModel)
  {
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
    local NetID = ID[0];
    if (NetID == "BOT")
      return true;
    return false;
  }

  CheckPrecache = function()
  {
    local ModelSet = [Survivors, LightModels];
    SurvSwap.ConLog("Checking for missing survivor models in precache...");
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
  }

  Initialized = function()
  {
    SurvSwap.ConLog("Survivor Swap has been initialized.");
  }
}

SurvSwap.Func.CheckPrecache();
SurvSwap.Func.Initialized();

__CollectEventCallbacks(SurvSwap.Func, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
