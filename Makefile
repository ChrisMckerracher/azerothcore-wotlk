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

	# copy third party modules
	cp -r third-party/* $(BASE_FOLDER)/modules
	# docker setup is weird, so put sql files in a weird place
	cp -r $(BASE_FOLDER)/modules/mod-individual-progression/data/sql/world/base/* $(BASE_FOLDER)/data/sql/custom/db_world/

	@if [ "$(BASE_FOLDER)" != "playerbots" ]; then \
		echo "removing $(BASE_FOLDER)/modules/mod-playerbots"; \
		rm -rf $(BASE_FOLDER)/modules/mod-playerbots; \
	fi

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

.PHONY: init-data
init-data:
	docker cp ac-worldserver:/azerothcore/env/dist/data ./data
	7z x ./third-party/mod-individual-progression/optional/dbc.7z -o./data/dbc -y
	mv data default/datamount # ToDo: don't hardcode default
	# ToDo: update docker-compose to mount this
	# or actual todo: make your own init-data that isupdated :)
