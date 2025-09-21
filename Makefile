export BASE_FOLDER=playerbots
.PHONY: install
install:
	# clean the modules folder
	cd $(BASE_FOLDER) && git checkout HEAD -- modules
	cd $(BASE_FOLDER) && git checkout HEAD -- data

	# copy third party modules
	cp -r third-party/* $(BASE_FOLDER)/modules

	# for some reason, sql stuff isnt working properly, manual override
	# ToDo: Generalize this
	#cp -r $(BASE_FOLDER)/modules/mod-individual-progression
	# ToDo: I think these folders need to be renamed to db-*
	# fucking this is bullshit
	#find $(BASE_FOLDER)/modules -type f -path '*/data/sql/updates/db_*/*.sql' -exec cp -v {} $(BASE_FOLDER)/data/sql/custom/test \;
	cp -r $(BASE_FOLDER)/modules/mod-individual-progression/data/sql/world/base/* $(BASE_FOLDER)/data/sql/custom/db_world/

	# copy first party modules
	# copy scripts

	# run
	docker compose -f $(BASE_FOLDER)/docker-compose.yml build --no-cache && docker compose -f $(BASE_FOLDER)/docker-compose.yml  up
	#docker compose -f $(BASE_FOLDER)/docker-compose.yml up

.PHONY: install-nobots
install-nobots: BASE_FOLDER=default
install-nobots: install

# Navigate to your AzerothCore modules directory
 #cd <azerothcore-path>/modules
 #
 ## Clone the mod-eluna repository
 #git clone https://github.com/azerothcore/mod-eluna.git
 #
 ## Configure build with your preferred Lua version
 #cd <azerothcore-build-directory>
 #cmake ../ -DLUA_VERSION=luajit  # Options: luajit, lua52, lua53, lua54
 #
 ## Default: If no version is specified, Lua 5.2 will be used
 #
 ## Rebuild your AzerothCore server
 #make -j$(nproc)

# ToDo: make this better structured, in the Dockerfile
#the git config line gets commented out, and the cmake line loses and and
    ##git config --global --add safe.directory /azerothcore && \
    #cmake /azerothcore \
