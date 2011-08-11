TARGETS := help all gh-pages comments backup push
.PHONY : $(TARGETS)

MD_FILES := $(wildcard *.md)
HTML_FILES := $(MD_FILES:.md=.html)

TO_TITLE_PL := \
	$$_ = $$ARGV[0]; \
	s/\.md$$//; \
	s/^(\w)/\U$$1/; \
	s/(?:-)(\w)/ \U$$1/g; \
	print;

help :
	@echo make targets: $(TARGETS)

all : gh-pages comments push

backup :
	-git add -- *.md *.html
	-git commit -m 'backup commit'

gh-pages : $(HTML_FILES) backup
	git checkout $@
	git checkout master -- $(HTML_FILES)
	git add -- $(HTML_FILES)
	git commit -m 'update $@'
	git checkout master

comments : backup
	git checkout $@
	@for file in $(MD_FILES); do if [ ! -f $$file ]; then \
		title=`perl -e '$(TO_TITLE_PL)' $$file`; \
		git checkout master -- $$file; \
		git add -- $$file; \
		git commit -m "post comments to '$$title' here"; \
	fi; done
	git checkout master

push :
	git push --all

%.html : %.md header.pl footer.pl
	perl header.pl $< >$@
	perl Markdown.pl --html4tags $< >>$@
	perl footer.pl $< >>$@
