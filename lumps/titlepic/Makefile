all: titlepic

titlepic: bsphemtl.png bsphdmtl.png

bsphemtl.png: titlepic.png
	magick convert $< -pointsize 10 -gravity east -font NimbusRoman-Bold -fill white -draw "text 5,95 '$(VERSION)'" $@
	cp $@ ../
	
bsphdmtl.png: blasphdm_title.png
	magick convert $< -pointsize 10 -gravity east -font NimbusRoman-Bold -fill white -draw "text 5,95 '$(VERSION)'" $@
	cp $@ ../
	
clean:
	$(RM) bsphemtl.png bsphdmtl.png                  \
	    ../bsphemtl.png ../bsphdmtl.png 
