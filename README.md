# dontstarvetogether
Project for setting up a DST server on a linux box

Currently this has been created on/for gentoo-based boxes (specifically funtoo servers)

## Pre-requisites
On a 64-bit system, 32-bit support is added and the following libraries are installed:

* libstdc++6:i386
* libgcc1:i386
* libcurl4-gnutls-dev:i386
    * for libcurl4-gnutls in gentoo/funtoo, you can just symlink this file into your most recent libcurl file
    * this will solve a lot of issues for rolling release distros (had similiar issues when I used Arch Linux)

    ```
    cd /usr/lib32 && ln -s libcurl.so libcurl-gnutls.so.4
    ```

## Getting Started (quick-and-easy)
These steps are meant for first timers, with absolutely no preconfigured setups.  
This means that both Steam and Don't Starve Togther have not yet been installed on the server and a server with default settings will be created

1. Clone this repository
2. Go to the scripts directory
3. Run the setupServer.sh script

The above steps will create a start server script called "DST-Server.sh" in the user's home folder, install steamcmd to $HOME/steamcmd, install Don't Starve Together at $HOME/.klei and create the configuration files at $HOME/.klei/DoNotStarveTogether/DST-Server

# Setting up a new server with custom settings
Please follow these steps in order to setup a custom server

1. Copy the file conf/default.conf into a file with the intended name of your server

    ```
    cp -v conf/default.conf conf/MyDSTserver.conf
    ``` 
    * Note: All config files should be kept in the conf folder and their file names should end with ".conf"
2. Run the setupServer.sh script with the "-conf" parameter of the new server

## Workflow

initially, this will be a setup following the guide from the klei dst dedicated server forums  
[Dedicated Server Quick Setup Guide - Linux](https://forums.kleientertainment.com/topic/64441-dedicated-server-quick-setup-guide-linux/)

Upcoming work in Scope:
* externalize mod list file so that it easy to add and remove mods
* add in additional checks for conflicting port settings within a server cluster
* find a workflow to package and containerize the installation in an extremely lightweight manner for portability onto other linux distributions
