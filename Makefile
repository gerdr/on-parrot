MD_FILES := $(wildcard *.md)
HTML_FILES := $(MD_FILES:.md=.html)

.PHONY : html

html : $(HTML_FILES)

%.html : %.md header.pl footer.pl
	perl header.pl $< >$@
	perl Markdown.pl --html4tags $< >>$@
	perl footer.pl $< >>$@
