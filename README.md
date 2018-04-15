# dontstarvetogether
Project for setting up a DST server on a linux box

Currently this is meant for Gentoo/Funtoo boxes

## Pre-requisites
linux operating system, gentoo-based distribution
packages are installed:
    layman:steam-overlay
    steam-launcher
    liberation-fonts
    media-libs/libtxc_dxtn (USE='abi_x86_32')

## Workflow
initially, this will be a setup following the guide from the klei dst dedicated server forums

[Dedicated Server Quick Setup Guide - Linux](https://forums.kleientertainment.com/topic/64441-dedicated-server-quick-setup-guide-linux/)

### Work in Scope:
* rebuild start script to generate config files upon start
* make use of an externalized mod list file so that it easy to add and remove mods
* find a workflow to package and containerize the installation in an extremely lightweight manner for portability onto other linux distributions


# Setting up a new server
Please follow these steps in order to setup a new server
1. Copy the file conf/default.conf into a file with the intended name of your server

    ```cp -v conf/default.conf conf/MyDSTserver.conf``` 

    *Note: All config files should be kept in the conf folder 

2. Run the setupNewServer.sh script
