
build:	clean
	./build.sh

clean:
	rm -f *.cfg
	rm -rf ~/install/Gamedata/ContractPacks/Spacetux/SpriteMissions


install: 
	@cd ~/github/SpaceTux/GameData/spacetux && make install
	mkdir ~/install/Gamedata/ContractPacks/Spacetux/SpriteMissions
	cp *cfg ~/install/Gamedata/ContractPacks/Spacetux/SpriteMissions
	cp *craft ~/install/Gamedata/ContractPacks/Spacetux/SpriteMissions
	cp sprite_flag.png SpriteMissions.version ~/install/Gamedata/ContractPacks/Spacetux/SpriteMissions

release:
	./update.sh
