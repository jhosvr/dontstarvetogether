# dontstarvetogether
Project for easy set up and configuration of a Don't Starve Together Dedicated Server on a linux box

Currently this has been created on/for gentoo-based boxes (specifically funtoo compute servers)

## Pre-requisites
On a 64-bit system, 32-bit support is added and the following libraries are installed (required for steamcmd):

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

The above steps will do the following:

* Create all necessary files for a DST server in the base folder $HOME/dst-server, which includes:
    * Installs steamcmd to dst-server/steamcmd
    * Installs DST to dst-server/dst
    * Generates server configs for a server "dstserver01" in dst-server/servers/dstserver01
    * Generates a mod list saved at dst-server/servers/dstserver01
    * Generates a start server script, which at runtime will update the game and generate necessary mod config files

# Setting up a new server with custom settings
Please follow these steps in order to setup a custom server

1. Copy the file conf/default.conf into a file with the intended name of your server

    ```
    cp -v conf/default.conf conf/MyOwnServer.conf
    ``` 
    * Note: All config files should be kept in the conf folder and their file names should end with ".conf"
2. Run the setupServer.sh script with the "-conf" parameter of the new server
    ```
    cp -v conf/default.conf conf/MyOwnServer.conf
    ./setupServer.sh -conf MyOwnServer.conf
    ``` 

## Features to still add

Upcoming work in scope:
* add in additional checks for conflicting port settings within a server cluster
* add in additional checks for pre-requisite libraries, and install if needed
  * Debian-based distributions
  * Rpm based distributions
  * Arch based distributions

When this repository is fleshed out with the above features, I will start looking into creating a python version for portability onto other systems (Windows, Mac)
