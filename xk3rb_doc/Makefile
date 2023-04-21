ALL = XK3RB_sci.html XK3RB_sci.txt XK3RB_tech.html XK3RB_tech.txt


.PHONY: all clean

all: $(ALL)

clean:
	$(RM) -f $(ALL)

%.html: %.md
	pandoc -S -s --mathjax --toc $< -o $@

%.txt: %.md
	pandoc $< --toc -o $@
