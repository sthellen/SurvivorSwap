// Database file for Survivor Swap.
// =========================================================================
// Survivor Swap
// Version: Check SurvivorSwap.nut
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
    francislight = { Model = "models/survivors/survivor_biker_light.mdl",     Name = "FrancisLight" }
    zoeylight    = { Model = "models/survivors/survivor_teenangst_light.mdl", Name = "ZoeyLight"    }
  }
}
