# High-Risk Loot Drop (Eluna)

These scripts mirror the behavior of the C++ high-risk system using Eluna. A chest is spawned at the death location of any non-instanced player and all carried items are migrated into it, allowing other players to loot the corpse contents.

Place the files in this directory inside your `lua_scripts` load path (or adjust `mod-eluna` configuration) to enable the high-risk death drops implemented in Lua.

## Database setup

Run the SQL migration under `scripts/high-risk/sql/db_world/` against your world database before starting the worldserver. It creates the custom chest template entry (`900001`) with an empty loot table that the Lua script expects.
