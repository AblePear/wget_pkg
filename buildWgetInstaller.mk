# Copyright (c) 2014, Able Pear Software. All rights reserved.
# Distributed under the GNU General Public License, version 3.
#
# Build wget and installer package from within Xcode


INSTALL_DIR := $(DERIVED_SOURCES_DIR)/Installed

SCRIPTS := $(shell find $(SRCROOT)/Scripts -type f \! -name .DS_Store)
STATIC_FILES := $(shell find $(SRCROOT)/Root -type f \! -name .DS_Store)
WGET_FILES := \
    usr/local/bin/wget \
    usr/local/etc/wgetrc \
    usr/local/share/info/wget.info \
    usr/local/share/man/man1/wget.1

INSTALLED_STATIC_FILES := $(patsubst $(SRCROOT)/Root/%,$(INSTALL_DIR)/%,$(STATIC_FILES))
INSTALLED_WGET_FILES := $(addprefix $(INSTALL_DIR)/,$(WGET_FILES))

INSTALLED_FILES := $(INSTALLED_STATIC_FILES) $(INSTALLED_WGET_FILES)


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
		--identifier com.ablepear.wget \
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
	cp -R $(SRCROOT)/Root/ $(INSTALL_DIR)/
	DESTDIR=$(INSTALL_DIR) $(MAKE) -C $(DERIVED_SOURCES_DIR)/Source install


# Copy source and configure
$(DERIVED_SOURCES_DIR)/Source/Makefile : $(SRCROOT)/configureWgetInstaller.sh $(SRCROOT)/Source/configure | $(DERIVED_SOURCES_DIR)
	@echo --- Configuring wget ---
	-rm -rf $(DERIVED_SOURCES_DIR)/Source
	cp -R $(SRCROOT)/Source/ $(DERIVED_SOURCES_DIR)/Source/
	cd $(DERIVED_SOURCES_DIR)/Source; sh $(SRCROOT)/configureWgetInstaller.sh


$(BUILT_PRODUCTS_DIR) :
	mkdir -p $(BUILT_PRODUCTS_DIR)


$(DERIVED_SOURCES_DIR) :
	mkdir -p $(DERIVED_SOURCES_DIR)
