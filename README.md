# dontstarvetogether
Project for setting up a DST server on a linux box
Currently this is meant for Gentoo/Funtoo boxes

## prerequisites
linux operating system, gentoo-based distribution
packages are installed:
    layman:steam-overlay
    steam-launcher
    liberation-fonts
    media-libs/libtxc_dxtn (USE='abi_x86_32')

### workflow
initially, this will be a setup following the guide from the [klei dst dedicated server forums](https://forums.kleientertainment.com/topic/64441-dedicated-server-quick-setup-guide-linux/)

in scope:
* rebuild start script to generate config files upon start
* make use of an externalized mod list file so that it easy to add and remove mods
* find a workflow to package and containerize the installation in an extremely lightweight manner for portability onto other linux distributions
