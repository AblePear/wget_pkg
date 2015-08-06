TMP ?= $(abspath tmp)

version := 1.16.3
installer_version := 1
configure_flags := --with-ssl=openssl


.PHONY : all
all : wget-$(version).pkg


.PHONY : clean
clean :
	-rm -f wget-$(version).pkg
	-rm -rf $(TMP)


##### dist ##########
dist_sources := $(shell find dist -type f \! -name .DS_Store)

$(TMP)/install/usr/local/bin/wget : $(TMP)/build/src/wget | $(TMP)/install
	cd $(TMP)/build && $(MAKE) DESTDIR=$(TMP)/install install

$(TMP)/build/src/wget : $(TMP)/build/config.status $(dist_sources)
	cd $(TMP)/build && $(MAKE)

$(TMP)/build/config.status : dist/configure | $(TMP)/build
	cd $(TMP)/build && sh $(abspath dist/configure) $(configure_flags)

$(TMP)/build \
$(TMP)/install :
	mkdir -p $@


##### pkg ##########

$(TMP)/wget-$(version).pkg : \
        $(TMP)/install/usr/local/bin/wget \
        $(TMP)/install/etc/paths.d/wget.path
	pkgbuild \
        --root $(TMP)/install \
        --identifier com.ablepear.wget \
        --ownership recommended \
        --version $(version) \
        $@

$(TMP)/install/etc/paths.d/wget.path : wget.path | $(TMP)/install/etc/paths.d
	cp $< $@

$(TMP)/install/etc/paths.d :
	mkdir -p $@


##### product ##########

wget-$(version).pkg : \
        $(TMP)/wget-$(version).pkg \
        $(TMP)/distribution.xml \
        $(TMP)/resources/background.png \
        $(TMP)/resources/license.html \
        $(TMP)/resources/welcome.html
	productbuild \
        --distribution $(TMP)/distribution.xml \
        --resources $(TMP)/resources \
        --package-path $(TMP) \
        --version $(installer_version) \
        --sign 'Able Pear Software Incorporated' \
        $@

$(TMP)/distribution.xml \
$(TMP)/resources/welcome.html : $(TMP)/% : % | $(dir $@)
	sed -e s/{{version}}/$(version)/g $< > $@

$(TMP)/resources/background.png \
$(TMP)/resources/license.html : $(TMP)/% : % | $(TMP)/resources
	cp $< $@

$(TMP) \
$(TMP)/resources :
	mkdir -p $@

