//#region
// =========================================================================
// Survivor Swap
// Version: 2026.03.21_0019
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
//#endregion

IncludeScript("SurvSwapDB");

SurvSwap.Func <-
{
  Survivors = ::SurvSwap.Survivors
  LightModels = ::SurvSwap.LightModels
  ConLog = ::SurvSwap.ConLog

  OnGameEvent_player_first_spawn = function(params)
  {
    if ( !IsValid(params.userid) ) return;
    local Player = GetPlayerFromUserID(params.userid);
    local CurrentModel = Player.GetModelName();
    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_player_transitioned = function(params)
  {
    if ( !IsValid(params.userid) ) return;
    local Player = GetPlayerFromUserID(params.userid);
    local CurrentModel = Player.GetModelName();
    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_player_entered_checkpoint = function(params)
  {
    if ( !Director.IsSessionStartMap() || !IsValid(params.userid) ) return;
    local Player = GetPlayerFromUserID(params.userid);
    local CurrentModel = Player.GetModelName();
    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_bot_player_replace = function(params)
  {
    if ( !IsValid(params.player) ) return;
    local Player = GetPlayerFromUserID(params.player);
    local CurrentModel = Player.GetModelName();
    SetSurvivorContext(Player, CurrentModel);
  }

  OnGameEvent_player_say = function(params)
  {
    if ( !IsValid(params.userid) ) return;

    local Player = GetPlayerFromUserID(params.userid);
    local NetID = Player.GetNetworkIDString();
    if (NetID == "BOT") return;

    local UserInput = params.text.tolower();
    if (UserInput[0] != '!') return;

    local Token = split(strip(UserInput.slice(1)), " ");
    local Character = Token[0];
    if ( !(Character in Survivors) ) return;

    local SayTarget = null;
    if (Token.len() == 2 && Token[1] != null)
    {
      SayTarget = Token[1];
    }

    if (SayTarget != null && SayTarget in Survivors)
    {
      SayTarget = FindSayTarget(SayTarget, Player, Character);
      if (SayTarget == null) return;
      SwapSurvivor(SayTarget, Character);
    }
    else
    {
      SwapSurvivor(Player, Character);
    }
  }

  FindSayTarget = function(SayTarget, Issuer, Character)
  {
    SayTarget = Survivors[SayTarget];
    local SurvSet = Director.GetSurvivorSet();
    SurvSet = SurvSet ^ 1 ? 0 : 1;
    if (SayTarget.Name[0].tolower() == Character) return;
    SayTarget = GetPlayerFromCharacter(SayTarget.Index[SurvSet]);
    if (SayTarget == null)
    {
      ClientPrint(Issuer, 5, "Target does not exist!");
      ClientPrint(Issuer, 5, "Syntax: ![desired survivor] [target]");
      return;
    }

    local NetID = SayTarget.GetNetworkIDString();
    if (NetID != "BOT")
    {
      Character = Survivors[Character];
      local InfoString = "Enter just \"!" + Character.Name[SurvSet].tolower() + "\" to change yourself.";
      ClientPrint(Issuer, 5, "Only bots can be targets!");
      ClientPrint(Issuer, 5, InfoString);
      ConLog("Swap failed: Only bots can be targets! " + InfoString);
      return null;
    }
    return SayTarget;
  }

  SwapSurvivor = function(Player, Character)
  {
    if (Player == null || Character == null) return;
    local CurrentModel = Player.GetModelName();
    local SurvSet = Director.GetSurvivorSet();
    SurvSet = SurvSet ^ 1 ? 0 : 1;
    Character = Survivors[Character];
    if (CurrentModel == Character.Model)
    {
      local InfoString = "Target is already " + Character.Name[SurvSet] + ".";
      ClientPrint(Player, 5, InfoString);
      ConLog("Swap failed: " + InfoString);
      return;
    }

    Player.SetModel(Character.Model);

    local SurvSet = Director.GetSurvivorSet();
    SurvSet = SurvSet ^ 1 ? 0 : 1;
    NetProps.SetPropIntArray(Player, "m_survivorCharacter", Character.Index[SurvSet], 0);

    SetSurvivorContext(Player, Character.Model);
    local PlayerName = Player.GetPlayerName();
    ConLog(PlayerName + "'s character was swapped to " + Character.Name[0] + "!");
  }

  SetSurvivorContext = function(Player, CurrentModel)
  {
    if (!Player.IsSurvivor()) return;
    local DisplayName = GetCharacterDisplayName(Player).tolower();
    local Character = Survivors[DisplayName];
    local ModelMatch = Character.Model == CurrentModel;
    ModelMatch = ModelMatch ? 0 : 1;
    local NetID = Player.GetNetworkIDString();
    if (NetID == "BOT")
    {
      SetFakeClientConVarValue(Player, "name", Character.Name[ModelMatch]);
    }
    Player.SetContext("who", Character.Context[ModelMatch], -1);
  }

  IsValid = function(User)
  {
    if (User == null || User == "") return false;
    local Player = GetPlayerFromUserID(User);
    if ( !Player.IsSurvivor() ) return false;
    return true;
  }

  CheckPrecache = function()
  {
    local ModelSet = [Survivors, LightModels];
    ConLog("Checking for missing survivor models in precache...");
    for (local i = 0; i < ModelSet.len(); i++)
    {
      foreach (Name, Value in ModelSet[i])
      {
        if (!IsModelPrecached(Value.Model))
        {
          ConLog( (typeof Value.Name == "string" ? Value.Name : Value.Name[0]) + " is not precached! Caching..." );
          PrecacheModel(Value.Model);
        }
      }
    }
    ConLog("All survivor models are precached!");
  }

  Initialized = function()
  {
    ConLog("Survivor Swap has been initialized.");
  }
}

SurvSwap.Func.CheckPrecache();
SurvSwap.Func.Initialized();

__CollectEventCallbacks(SurvSwap.Func, "OnGameEvent_", "GameEventCallbacks", RegisterScriptGameEventListener);
