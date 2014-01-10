GNU Wget 1.14 for OS X
======================

This project build a standard OS X installer package for GNU wget.

A recent version of Mac OS X and Xcode are required to build wget and the
installer.  The project and installer are tested on Mac OS X 10.9 "Mavericks"
and Xcode 5.0.2.

You can build wget and the installer from within Xcode or on the command line
by running the `build-project` script from the command line.  (Note that wget
currently builds with many warnings on OS X.)

The installer package adds the following files to your system:

 * `/etc/paths.d/11.usr_local_bin`
 * `/usr/local/bin/wget`
 * `/usr/local/etc/wgetrc`
 * `/usr/local/share/info/wget.info`
 * `/usr/local/share/man/man1/wget.1`

(The `11.usr_local_bin` file adds `/usr/local/bin` to your system path.)

## License

The installer and related scripts are copyright (c) 2014 Able Pear Software.
Wget and the installer are distributed under the GNU General Public License, 
version 3.  See the LICENSE file for details.
