# Bare Necessities Agent Notes

- Scope for automation is limited to `Code/azerothcore-wotlk/scripts/bare_necessities` for writable Lua modules. Treat `Code/azerothcore-wotlk/scripts/helpers` as read-only reference material.
- Lua scripts are installed into a flat folder and executed directly by Eluna; expose shared functions as globals and reference them without `require`.
- Keep the implementation straightforward—avoid unnecessary type checks or defensive wrappers when the calling context guarantees the value.
