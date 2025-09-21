export BASE_FOLDER=playerbots
.PHONY: install
install:
	# clean the modules folder
	cd $(BASE_FOLDER) && git checkout HEAD -- modules

	# copy third party modules
	cp -r third-party/* $(BASE_FOLDER)/modules

	# copy first party modules
	# copy scripts

	# run
	docker compose -f $(BASE_FOLDER)/docker-compose.yml up

.PHONY: install-nobots
install-nobots: BASE_FOLDER=default
install-nobots: install
