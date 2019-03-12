
%.subm: $(name).fls submission.mk
	awk '/INPUT .*\.$*/{print $$2}' $< | xargs readlink -ef | sort | uniq | grep -v "texlive" | sed -e "s~$$(pwd)/~~g" > $@

xbb.subm:  png.subm submission.mk
	sed -e 's/png/xbb/g' $< > $@

all.subm_from: sty.subm png.subm pdf.subm bb.subm tex.subm bbl.subm pygstyle.subm pygtex.subm
	cat $^ > $@

all.subm_to: all.subm_from
	tr "/" "^" < $< > $@

all.subm_fromto: all.subm_from all.subm_to
	paste all.subm_from all.subm_to > $@

submission: en all.subm_fromto

	mkdir -p submission
	while read from to ; do cp -v $$from submission/$$to ; done < all.subm_fromto

	while read from to ; do echo "$$from -> $$to" ; sed -i "s@$$from@$$to@g" submission/*.tex ; done < all.subm_fromto
	cd submission ; ../inline-tex $(name).tex

	find submission -name "*\.log" -delete
	find submission -name "*\.bbl" -delete

	find submission -type d -empty -exec rmdir {} \; # remove the empty directories
	ls submission
	cd submission ; pdflatex $(name).tex
	cd submission ; pdflatex $(name).tex
	cd submission ; pdflatex $(name).tex
	find submission -name "*\.log" -delete
	find submission -name "*\.bbl" -delete
	find submission -name "*\.aux" -delete
	find submission -name "*\.out" -delete
	@echo "Make sure every \\input commands are in the beginning of line but space"

clean-submission:
	-rm -rf *.subm submission *.tar.gz *.zip

archive: submission
	-rm submission/*.sty submission/*.bst
	cd submission ; tar cvzf ../$(name).tar.gz *
	cd submission ; zip -r ../$(name).zip *
