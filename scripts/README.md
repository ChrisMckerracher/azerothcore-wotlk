## Usage
Make all folders fake_module/sql/[db_characters/db_world/db_auth] for sql

Make your lua fake_module/*.lua, though i believe these can be nested?

Namespace your files, at the very least your lua files

## Namespacing

The installation of 'fake modules'(named as modules are an actual concept in azerothcore)
puts all modules in shared folders. Namespacing your files with a prefix eliminates a name
conflict issue

lua files are loaded in order, so function definitions can only be read in order if the file
naming suffices. this is garbo but whatever
