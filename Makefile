TARGETS := help all gh-pages comments backup push
.PHONY : $(TARGETS)

MD_FILES := $(wildcard *.md)
HTML_FILES := $(MD_FILES:.md=.html)
STATIC_FILES := styles.css

help :
	@echo make targets: $(TARGETS)

all : gh-pages comments push

backup :
	-git add -- *.md *.html $(STATIC_FILES)
	-git commit -m 'backup commit'

gh-pages : $(HTML_FILES) backup
	git checkout $@
	git checkout master -- $(STATIC_FILES) $(HTML_FILES)
	git add .
	-git commit -m 'update $@'
	git checkout master

comments : backup
	git checkout $@
	git checkout master -- messages.pl
	-for file in $(filter-out index.md,$(MD_FILES)); do \
		if [ -f $$file ]; then \
			msg=`perl messages.pl update $$file`; \
			git checkout master -- $$file; \
			git add -- $$file; \
			git commit -m "$$msg" -- $$file; \
		else \
			msg=`perl messages.pl create $$file`; \
			git checkout master -- $$file; \
			git add -- $$file; \
			git commit -m "$$msg" -- $$file; \
	fi; done
	git checkout master

push :
	git push --all

%.html : %.md header.pl footer.pl
	perl header.pl $< >$@
	perl Markdown.pl --html4tags $< >>$@
	perl footer.pl $< >>$@
