# Build wget from within Xcode


FILES := \
    usr/local/bin/wget \
    usr/local/etc/wgetrc \
    usr/local/share/info/wget.info \
    usr/local/share/man/man1/wget.1
INSTALL_DIR := $(DERIVED_SOURCES_DIR)/Installed
INSTALLED_FILES := $(addprefix $(INSTALL_DIR)/,$(FILES))
SCRIPTS := $(shell find $(SRCROOT)/Scripts -type f \! -name .DS_Store \! -path "*/.svn/*")


.PHONY : all clean


all : $(BUILT_PRODUCTS_DIR)/wget.pkg


clean :
	rm -rf $(BUILT_PRODUCTS_DIR)/wget.pkg
	rm -rf $(DERIVED_SOURCES_DIR)


# Create package from installed files
$(BUILT_PRODUCTS_DIR)/wget.pkg : $(INSTALLED_FILES) $(SCRIPTS) | $(BUILT_PRODUCTS_DIR)
	@echo --- Building wget package ---
	pkgbuild \
		--root $(INSTALL_DIR) \
		--identifier com.ablepear.server.wget \
		--ownership recommended \
		--scripts $(SRCROOT)/Scripts \
		$@


# Build and install to an alternate destination
$(INSTALLED_FILES) : $(DERIVED_SOURCES_DIR)/Source/Makefile
	@echo --- Building and installing wget ---
	$(MAKE) -C $(DERIVED_SOURCES_DIR)/Source
	# install
	-rm -rf $(INSTALL_DIR)
	mkdir -p $(INSTALL_DIR)
	DESTDIR=$(INSTALL_DIR) $(MAKE) -C $(DERIVED_SOURCES_DIR)/Source install


# Copy source and configure
$(DERIVED_SOURCES_DIR)/Source/Makefile : $(SRCROOT)/configure-wget.sh $(SRCROOT)/Source/configure | $(DERIVED_SOURCES_DIR)
	@echo --- Configuring wget ---
	-rm -rf $(DERIVED_SOURCES_DIR)/Source
	cp -R $(SRCROOT)/Source/ $(DERIVED_SOURCES_DIR)/Source/
	cd $(DERIVED_SOURCES_DIR)/Source; sh $(SRCROOT)/configure-wget.sh


$(BUILT_PRODUCTS_DIR) :
	mkdir -p $(BUILT_PRODUCTS_DIR)


$(DERIVED_SOURCES_DIR) :
	mkdir -p $(DERIVED_SOURCES_DIR)
