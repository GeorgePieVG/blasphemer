# SPDX-License-Identifier: BSD-3-Clause

# Blasphemer build script

VERSION="2024 v0.1.9-fork-008"
WADS=wads
SNDCURVE=scripts/blasphemer_sndcurve.py
CPP=scripts/simplecpp
DEUTEX=deutex
DEUTEX_BASIC_ARGS=-v0 -rate accept
DEUTEX_ARGS=$(DEUTEX_BASIC_ARGS) -heretic bootstrap/
NODE_BUILDER=ZenNode
NODE_BUILDER_LEVELS=e?m? dm??

BLASPHEM=$(WADS)/blasphem.wad
BLASPHDM=$(WADS)/blasphdm.wad

OBJS=$(BLASPHEM) $(BLASPHDM)

all: deutex-check $(OBJS)

subdirs:
	$(MAKE) VERSION=$(VERSION) -C lumps/titlepic
	$(MAKE) -C lumps/genmidi
	$(MAKE) -C lumps/dmxgus
	$(MAKE) -C lumps/textures

#---------------------------------------------------------
# Build checks

# Make sure deutex supports PNG
deutex-check:
	@$(DEUTEX) -h | grep -qw PNG || { \
	echo "$(DEUTEX) does not support PNG. Try building deutex with the PNG"; \
	echo "libraries (libpng and libpng-devel or similar packages) installed."; \
	echo "deutex can be downloaded from https://github.com/Doom-Utils/deutex."; \
	echo "The full path to duetex can be specified by passing"; \
	echo "DEUTEX=/the/path/to/deutex to make when building Blasphemer."; \
	exit 1; }

# Make sure that no PNG files are modified if scripts are to modify them.
pngs-modified-check:
	@{ ! git status -s | grep -q \\.png$ ; }  || { \
	echo "PNG fix targets can not be run if there are modified PNGs." ; \
	exit 1; }

#---------------------------------------------------------
# SNDCURVE lump generation
lumps/sndcurve.lmp: scripts/blasphemer_sndcurve.py
	python scripts/blasphemer_sndcurve.py

#---------------------------------------------------------
# BlasphDM iwad

wadinfo_blasphdm.txt : buildcfg.txt subdirs lumps/blasphem.lmp lumps/blasphdm.lmp
	$(CPP) -P -DBLASPHDM < $< > $@

$(BLASPHDM): wadinfo_blasphdm.txt subdirs
	@mkdir -p $(WADS)
	$(RM) $@
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -build wadinfo_blasphdm.txt $@

#---------------------------------------------------------
# blasphemer (SOTSR) iwad

wadinfo_blasphem.txt: buildcfg.txt subdirs lumps/blasphem.lmp
	$(CPP) -P -DBLASPHEM < $< > $@

$(BLASPHEM): wadinfo_blasphem.txt subdirs
	@mkdir -p $(WADS)
	$(RM) $@
	$(DEUTEX) $(DEUTEX_ARGS) -iwad -build wadinfo_blasphem.txt $@

clean: 
	rm $(BLASPHEM)
	rm $(BLASPHDM)
	rmdir $(WADS)
	rm wadinfo_blasphem.txt
	rm wadinfo_blasphdm.txt
	
	$(MAKE) -C lumps/titlepic clean
	$(MAKE) -C lumps/genmidi clean
	$(MAKE) -C lumps/dmxgus clean
	$(MAKE) -C lumps/textures clean

# Overwrite PNGs with what deutex extracts from the WADs produced.
fix-deutex-pngs: pngs-modified-check
	scripts/fix-deutex-pngs $(OBJS)

# Rebuild the nodes for the level WADs. By default this invokes "ZenNode" on
# all 100 level WADs. Override the "NODE_BUILDER" prefixed variables to
# configure.
rebuild-nodes: $(addprefix levels/,$(addsuffix .wad,$(NODE_BUILDER_LEVELS)))
	for level in $^; \
	do \
		$(NODE_BUILDER) $$level -o $$level; \
	done

prefix?=/usr/local
docdir?=/share/doc
mandir?=/share/man
waddir?=/share/games/doom
target=$(DESTDIR)$(prefix)

install:
	install -Dm 644 $(BLASPHEM) -t "$(target)$(waddir)"

uninstall:
	rm "$(target)$(waddir)/blasphem.wad" 

