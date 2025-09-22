export BASE_FOLDER=playerbots
.PHONY: install
install: install-modules install-scripts
	# clean the modules folder
	cd $(BASE_FOLDER) && git checkout HEAD -- data
	# run
	#docker compose -f $(BASE_FOLDER)/docker-compose.yml build --no-cache && docker compose -f $(BASE_FOLDER)/docker-compose.yml  up
	docker compose -f $(BASE_FOLDER)/docker-compose.yml up

.PHONY: install-nobots
install-nobots: BASE_FOLDER=default
install-nobots: install

.PHONY: install-modules
install-modules:
	rm -r $(BASE_FOLDER)/modules/*
	cd $(BASE_FOLDER) && git checkout HEAD -- modules
	# docker setup is weird, so put sql files in a weird place
	#cp -r $(BASE_FOLDER)/modules/mod-individual-progression/data/sql/world/base/* $(BASE_FOLDER)/data/sql/custom/db_world/

	# copy third party modules
	cp -r third-party/* $(BASE_FOLDER)/modules
	@if [ "$(MY_ENV_VAR)" != "playerbots" ]; then \
		rm -r $(BASE_FOLDER)/modules/mod-playerbots || true; \
	fi

	# but gate our rules about handling playerbots sql files
	# ToDo: I will need to wrap the appropriate Dockerfile to run a custom install script before calling the worldserver executable
	# ToDo: I may be able to base it on: https://github.com/coc0nut/AzerothCore-with-Playerbots-Docker-Setup/blob/main/setup.sh
	cp -r third-party/* $(BASE_FOLDER)/modules
	@if [ "$(MY_ENV_VAR)" = "playerbots" ]; then \
		cp -r $(BASE_FOLDER)/modules/mod-playerbots/data/sql/characters/base/* $(BASE_FOLDER)/data/sql/custom/db_characters; \
		cp -r $(BASE_FOLDER)/modules/mod-playerbots/data/sql/world/base/* $(BASE_FOLDER)/data/sql/custom/db_world; \
		cp -r $(BASE_FOLDER)/modules/mod-playerbots/data/sql/world/updates/* $(BASE_FOLDER)/data/sql/custom/db_world; \
		cp -r $(BASE_FOLDER)/modules/mod-playerbots/data/sql/playerbots $(BASE_FOLDER)/data/sql/custom/db_playerbots; \
	fi

.PHONY: install-scripts
install-scripts:
	rm -rf $(BASE_FOLDER)/lua_scripts || true

	# im sure theres some bullshit find thing but we'll copy scripts to two places and all it a day
	cp -r scripts $(BASE_FOLDER)/lua_scripts
	find $(BASE_FOLDER)/lua_scripts -type f ! -name "*.lua" -delete

	cp -r scripts/*/sql/* $(BASE_FOLDER)/data/sql/custom
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
