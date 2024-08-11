# The full set of graphics outputted by textgen includes a couple of
# extra files that are just intermediates, and are not lumps to be
# incuded in the WADs:

# all: help.png credit.png titlepic
all: titlepic

titlepic: bsphemtl.png bsphdmtl.png

bsphemtl.png: ../titlepic/titlepic.png
	./create_caption $< $@
	cp $@ ../
bsphdmtl.png: ../titlepic/blasphdm_title.png
	./create_caption $< $@
	cp $@ ../

clean:
	$(RM) bsphemtl.png bsphdmtl.png                  \
	    ../bsphemtl.png ../bsphdmtl.png 
	$(RM) __pycache__/*
	-rmdir __pycache__
