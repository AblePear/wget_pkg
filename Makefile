TMP ?= $(abspath tmp)

version := 1.17.1
installer_version := 3
openssl_configure_flags := no-shared darwin64-x86_64-cc
wget_configure_flags := \
		--with-ssl=openssl \
		--with-libssl-prefix=$(TMP)/openssl/install/usr/local/ssl

.SECONDEXPANSION :

.PHONY : all
all : wget-$(version).pkg


.PHONY : clean
clean :
	-rm -f wget-$(version).pkg
	-rm -rf $(TMP)


##### openssl ##########
openssl_sources := $(shell find openssl -type f \! -name .DS_Store)
openssl_dirs := $(shell find openssl -type d)

openssl_build_sources := \
		$(patsubst openssl/%, $(TMP)/openssl/build/%, $(openssl_sources))
openssl_build_dirs := \
		$(TMP)/openssl/build \
		$(patsubst openssl/%, $(TMP)/openssl/build/%, $(openssl_dirs))

openssl_install_files := \
		$(TMP)/openssl/install/usr/local/ssl/include/openssl/ssl.h \
		$(TMP)/openssl/install/usr/local/ssl/lib/libcrypto.a \
		$(TMP)/openssl/install/usr/local/ssl/lib/libssl.a

$(openssl_install_files) : $(TMP)/openssl/installed.stamp.txt
	@:

$(TMP)/openssl/installed.stamp.txt : \
				$(TMP)/openssl/build/ssl/ssl.h \
				$(TMP)/openssl/build/libssl.a \
				$(TMP)/openssl/build/libcrypto.a \
				| $(TMP)/openssl/install
	cd $(TMP)/openssl/build && $(MAKE) INSTALL_PREFIX=$(TMP)/openssl/install install_sw
	date > $@

$(TMP)/openssl/build/libssl.a \
$(TMP)/openssl/build/libcrypto.a : $(TMP)/openssl/built.stamp.txt | $$(dir $$@)
	@:

$(TMP)/openssl/built.stamp.txt : $(TMP)/openssl/configured.stamp.txt | $$(dir $$@)
	cd $(TMP)/openssl/build && $(MAKE)
	date > $@

$(TMP)/openssl/configured.stamp.txt : $(openssl_build_sources) | $$(dir $$@)
	cd $(TMP)/openssl/build && sh ./Configure $(openssl_configure_flags)
	date > $@

$(openssl_build_sources) : $(TMP)/openssl/build/% : openssl/% | $$(dir $$@)
	cp $< $@


$(TMP)/openssl \
$(TMP)/openssl/install \
$(openssl_build_dirs) :
	mkdir -p $@


##### wget ##########
wget_sources := $(shell find wget -type f \! -name .DS_Store)

$(TMP)/wget/install/usr/local/bin/wget : $(TMP)/wget/build/src/wget | $(TMP)/wget/install
	cd $(TMP)/wget/build && $(MAKE) DESTDIR=$(TMP)/wget/install install

$(TMP)/wget/build/src/wget : $(TMP)/wget/build/config.status $(wget_sources)
	cd $(TMP)/wget/build && $(MAKE)

$(TMP)/wget/build/config.status : \
				wget/configure \
				$(openssl_install_files) \
				| $(TMP)/wget/build
	cd $(TMP)/wget/build && sh $(abspath wget/configure) $(wget_configure_flags)

$(TMP)/wget/build \
$(TMP)/wget/install :
	mkdir -p $@


##### pkg ##########

$(TMP)/wget-$(version).pkg : \
        $(TMP)/wget/install/usr/local/bin/wget \
        $(TMP)/wget/install/etc/paths.d/wget.path
	pkgbuild \
        --root $(TMP)/wget/install \
        --identifier com.ablepear.wget \
        --ownership recommended \
        --version $(version) \
        $@

$(TMP)/wget/install/etc/paths.d/wget.path : wget.path | $(TMP)/wget/install/etc/paths.d
	cp $< $@

$(TMP)/wget/install/etc/paths.d :
	mkdir -p $@


##### product ##########

wget-$(version).pkg : \
        $(TMP)/wget-$(version).pkg \
        $(TMP)/distribution.xml \
        $(TMP)/resources/background.png \
        $(TMP)/resources/licenses.html \
        $(TMP)/resources/welcome.html
	productbuild \
        --distribution $(TMP)/distribution.xml \
        --resources $(TMP)/resources \
        --package-path $(TMP) \
        --version $(installer_version) \
        --sign 'Able Pear Software Incorporated' \
        $@

$(TMP)/distribution.xml \
$(TMP)/resources/welcome.html : $(TMP)/% : % | $$(dir $$@)
	sed -e s/{{version}}/$(version)/g $< > $@

$(TMP)/resources/background.png \
$(TMP)/resources/licenses.html : $(TMP)/% : % | $(TMP)/resources
	cp $< $@

$(TMP) \
$(TMP)/resources :
	mkdir -p $@

