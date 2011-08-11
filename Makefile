MD_FILES := $(wildcard *.md)
HTML_FILES := $(MD_FILES:.md=.html)

.PHONY : html push

html : $(HTML_FILES)

push : html
	git checkout gh-pages
	git checkout master $(HTML_FILES)
	git commit -a -m "update gh-pages"

%.html : %.md header.pl footer.pl
	perl header.pl $< >$@
	perl Markdown.pl --html4tags $< >>$@
	perl footer.pl $< >>$@
