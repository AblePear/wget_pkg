TMP ?= $(abspath tmp)
pkg_version := 1
wget_version := 1.14
configure_flags := --with-ssl=openssl


.PHONY : all
all : wget.pkg


.PHONY : clean
clean :
	-rm -f wget.pkg
	-rm -rf $(TMP)


wget.pkg : \
        $(TMP)/wget.pkg \
        resources/background.png \
        resources/distribution.xml \
        resources/license.html \
        resources/welcome.html
	productbuild \
        --distribution resources/distribution.xml \
        --resources resources \
        --package-path $(TMP) \
        --version $(pkg_version) \
        --sign 'Able Pear Software Incorporated' \
        $@


src := $(shell find wget -type f \! -name .DS_Store)
build_dir := $(TMP)/build
install_dir := $(TMP)/install


$(TMP)/wget.pkg : $(install_dir)/usr/local/bin/wget | $(TMP)
	pkgbuild \
        --root $(install_dir) \
        --identifier com.ablepear.wget \
        --ownership recommended \
        --version $(wget_version) \
        $@


$(install_dir)/usr/local/bin/wget : $(build_dir)/src/wget | $(install_dir)
	cd $(build_dir) && $(MAKE) DESTDIR=$(install_dir) install


$(build_dir)/src/wget : $(build_dir)/config.status $(src)
	cd $(build_dir) && $(MAKE)


$(build_dir)/config.status : wget/configure | $(build_dir)
	cd $(build_dir) && sh $(abspath wget/configure) $(configure_flags)


$(TMP) \
$(build_dir) \
$(install_dir) :
	mkdir -p $@

