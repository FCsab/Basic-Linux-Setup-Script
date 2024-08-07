#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo, use sudo bash setup.sh" exit 1
fi

function get_selecion(){
    echo "Would like to install all packages listed on GitHub? y/n"
    read all
    if [[ "$all" == "y" ]]; then
        basic="y"
        tools="y"
        gaming="y"
        return 0
    fi

    echo "Would you like to install the basic packages? y/n"
    read basic

    echo "Would you like to install the development packages? y/n"
    read tools

    echo "Would you like to install the gaming packages? y/n"
    read gaming
}

get_selecion

if [[ $(dnf --version) ]];
    then system="Fedora"
fi
if [[ $(apt --version) ]];
    then system="Debian"
fi

directory=$(pwd)

echo "$system detected on your computer."

function install_steam(){
     if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; then
      echo "Downloading steam repo" >> failed.txt
      return 1
    fi

    if ! sudo dnf config-manager --set-enabled fedora-cisco-openh264 -y; then
      echo "Enabling steam repo" >> failed.txt
      return 1
    fi

    if ! sudo dnf install -y steam; then
      echo "Installing Steam" >> failed.txt
      return 1
    fi
    echo "Steam installation successful!"
    fi

    if [[ "$system" == "Debian" ]]; then
        if ! sudo echo "deb http://deb.debian.org/debian/ bookworm main contrib non-free" >> /etc/apt/sources.list; then
            echo "Adding steam repo" >> failed.txt
            return 1
        fi
        if ! sudo dpkg --add-architecture i386; then
            echo "Updating apt" >> failed.txt
            return 1
        fi
        if ! sudo apt update; then
            echo "Updating apt" >> failed.txt
            return 1
        fi
        if ! sudo apt install -y steam-installer; then
            echo "Installing Steam" >> failed.txt
            return 1
        fi
        if ! apt install mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386; then
            echo "Installing Steam dependencies" >> failed.txt
            return 1
        fi
        echo "Steam installation successful!"
    fi
}

function post_install_setup(){
     if [[ "$system" == "Fedora" ]]; then
     sudo cp /etc/dnf/dnf.conf /etc/dnf/dnf.conf.bak
        if ! sudo echo "[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=1
max_parallel_downloads=10
deltarpm=true" > /etc/dnf/dnf.conf; then
    echo "DNF config" >> failed.txt
    sudo rm /etc/dnf/dnf.conf
    sudo mv /etc/dnf/dnf.conf.bak /etc/dnf/dnf.conf
    return 1
fi
fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install nala -y; then
            echo "Installing Nala" >> failed.txt
            return 1
        fi
    fi
}

function install_codecs(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing -y; then
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y; then
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf install ffmpeg ffmpeg-libs libva libva-utils -y; then
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf config-manager --set-enabled fedora-cisco-openh264 -y; then
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264 -y; then
                echo "codecs" >> failed.txt
                return 1
        fi
    echo "Codecs installation successful!"
    fi
}

function install_protonge(){
    username=$(logname)
    if [[ "$system" == "Fedora" ]] || [[ "$system" == "Debian" ]]; then
            if ! wget -P /home/$username/Downloads https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-11/GE-Proton9-11.tar.gz; then
                echo "ProtonGe download" >> failed.txt
                return 1
            fi
            if ! mkdir /home/$username/.steam; then
                    echo "ProtonGe folder creation" >> failed.txt
                    return 1
            fi
            if ! mkdir /home/$username/.steam/root; then
                    echo "ProtonGe folder creation" >> failed.txt
                    return 1
            fi
            if ! mkdir /home/$username/.steam/root/compatibilitytools.d/; then
                    echo "ProtonGe folder creation" >> failed.txt
                    return 1
            fi
            if ! sudo chown -R $username:$username /home/$username/.steam; then
            echo "ProtonGe folder ownership" >> failed.txt
            return 1
        fi
            if ! tar -xf /home/$username/Downloads/GE-Proton9-11.tar.gz -C /home/$username/.steam/root/compatibilitytools.d/; then
                    echo "ProtonGe extract" >> failed.txt
                    return 1
            fi
            if ! rm /home/$username/Downloads/GE-Proton9-11.tar.gz; then
                    echo "ProtonGe clean" >> failed.txt
                    return 1
            fi
        fi
}

function install_git(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install git -y
            then
                echo "Installing git" >> failed.txt
                return 1
        fi
        if ! flatpak install flathub io.github.shiftey.Desktop -y; then
                echo "Installing GitHub Desktop" >> failed.txt
                return 1
        echo "Git installation successful!"
    fi
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install git -y; then
                echo "Installing git" >> failed.txt
                return 1
        fi
        if ! flatpak install flathub io.github.shiftey.Desktop -y; then
                echo "Installing GitHub Desktop" >> failed.txt
                return 1
        echo "Git installation successful!"
    fi
        echo "Git installation successful!"
    fi
}

function install_discord(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm; then
                echo "Adding Discord repo" >> failed.txt
                return 1
        fi
        if ! sudo dnf update -y; then
                echo "Updating for Discord" >> failed.txt
                return 1
        fi
        if ! sudo dnf install discord -y; then
                echo "Installing Discord" >> failed.txt
                return 1
        fi
        echo "Discord installation successful!"
    fi


    if [[ "$system" == "Debian" ]]; then
        if ! flatpak install flathub com.discordapp.Discord -y; then
                echo "Installing discord" >> failed.txt
                return 1
        fi
        echo "Discord installation successful!"
    fi
}

function install_grubcostum(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install grub-customizer -y; then
                echo "Installing Grub Customizer" >> failed.txt
                return 1
        fi
        echo "Grub Customizer installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install grub-customizer -y
            then
                echo "Installing Grub Customizer" >> failed.txt
                return 1
        fi
        echo "Grub Customizer installation successful!"
    fi 
}

function install_gimp(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install gimp -y; then
                echo "Installing GIMP" >> failed.txt
                return 1
        fi
        echo "GIMP installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install gimp -y; then
                echo "Installing GIMP" >> failed.txt
                return 1
        fi
        echo "GIMP installation successful!"
    fi
}

function install_fish(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install fish -y; then
                echo "Installing Fish" >> failed.txt
                return 1
        fi
        echo "Fish installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install fish -y; then
                echo "Installing Fish" >> failed.txt
                return 1
        fi
        echo "Fish installation successful!"
    fi
}

function install_vscode(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null; then
                return 1
                echo "Importing key for Visual Studio Code" >> failed.txt
        fi
        if ! sudo dnf check-update; then
                echo "Checking for updates for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! sudo dnf install code -y; then
                echo "Installing Visual Studio Code" >> failed.txt
                return 1
        fi
        echo "Visual Studio Code installation successful!"
    fi


    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt-get install wget gpg; then
                echo "Installing VS code dependencies" >> failed.txt
                return 1
        fi
        if ! wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; then
                echo "Downloading key for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg; then
                echo "Installing key for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null; then
                echo "Adding Visual Studio Code repo" >> failed.txt
                return 1
        fi
        if ! rm -f packages.microsoft.gpg; then
                echo "Cleaning up VS code" >> failed.txt
                return 1
        fi
        if ! sudo apt install apt-transport-https; then
                echo "Installing apt transport for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! sudo apt update; then
                echo "Updating for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! sudo apt install code -y; then
                echo "Installing Visual Studio Code" >> failed.txt
                return 1
        fi
        echo "Visual Studio Code installation successful!"
    fi
}

function set_up_flatpak(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install flatpak -y; then
                echo "Installing Flatpak" >> failed.txt
                return 1
        fi
        if ! flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
                echo "Adding Flathub" >> failed.txt
                return 1
        fi
        echo "Flatpak installation successful!"
    fi


    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install flatpak -y; then
                echo "Installing Flatpak" >> failed.txt
                return 1
        fi
        if ! flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
                echo "Adding Flathub" >> failed.txt
                return 1
        fi
        echo "Flatpak installation successful!"
    fi
}

function install_libre_office(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install libreoffice -y; then
                echo "Installing Libre Office" >> failed.txt
                return 1
        fi
        echo "Libre Office installation successful!"
    fi


    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install libreoffice -y; then
                echo "Installing Libre Office" >> failed.txt
                return 1
        fi
        echo "Libre Office installation successful!"
    fi
}

function install_obsidian(){
    if [[ "$system" == "Fedora" ]] || [[ "$system" == "Debian" ]]; then
        if ! flatpak install flathub md.obsidian.Obsidian -y; then
                echo "Installing Obsidian" >> failed.txt
                return 1
        fi
        echo "Obsidian installation successful!"
    fi
}

function install_modrinth(){
    if [[ "$system" == "Fedora" ]] || [[ "$system" == "Debian" ]]; then
        if ! flatpak install flathub com.modrinth.ModrinthApp -y; then
                echo "Installing Modrinth" >> failed.txt
                return 1
        fi
        echo "Modrinth installation successful!"
    fi
}

function install_retroarch(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install retroarch -y; then
                echo "Installing Retroarch" >> failed.txt
                return 1
        fi
        echo "Retroarch installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt-get install retroarch -y; then
                echo "Installing Retroarch" >> failed.txt
                return 1
        fi
        echo "Retroarch installation successful!"
    fi
}

function install_keepassxc(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install keepassxc -y; then
                echo "Installing KeepassXC" >> failed.txt
                return 1
        fi
        echo "KeepassXC installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install keepassxc -y; then
                echo "Installing KeepassXC" >> failed.txt
                return 1
        fi
        echo "KeepassXC installation successful!"
    fi
}

function install_transmission(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install transmission -y; then
                echo "Installing Transmission" >> failed.txt
                return 1
        fi
        echo "Transmission installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install transmission -y; then
                echo "Installing Transmission" >> failed.txt
                return 1
        fi
        echo "Transmission installation successful!"
    fi
}

function install_shotcut(){
    if [[ "$system" == "Fedora" ]] || [[ "$system" == "Debian" ]]; then
        if ! flatpak install flathub org.shotcut.Shotcut -y; then
                echo "Installing Shotcut" >> failed.txt
                return 1
        fi
        echo "Shotcut installation successful!"
    fi
}

function install_neofetch(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install neofetch -y; then
                echo "Installing Neofetch" >> failed.txt
                return 1
        fi
        echo "Neofetch installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install neofetch -y; then
                echo "Installing Neofetch" >> failed.txt
                return 1
        fi
        echo "Neofetch installation successful!"
    fi
}

function install_kitty(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install kitty -y; then
                echo "Installing Kitty" >> failed.txt
                return 1
        fi
        echo "Kitty installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install kitty -y; then
                echo "Installing Kitty" >> failed.txt
                return 1
        fi
        echo "Kitty installation successful!"
    fi
}

function install_openrgb(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install openrgb -y; then
                echo "Installing OpenRGB" >> failed.txt
                return 1
        fi
        echo "OpenRGB installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! flatpak install flathub org.openrgb.OpenRGB -y; then
                echo "Installing OpenRGB" >> failed.txt
                return 1
        fi
        echo "OpenRGB installation successful!"
    fi
}

function install_mangohud(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install mangohud -y; then
                echo "Installing MangoHud" >> failed.txt
                return 1
        fi
        echo "MangoHud installation successful!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt install mangohud -y; then
                echo "Installing MangoHud" >> failed.txt
                return 1
        fi
        echo "MangoHud installation successful!"
    fi
}

function update_system(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf update -y; then
                echo "Updating system" >> failed.txt
                return 1
        fi
        if ! sudo dnf upgrade -y; then
                echo "Upgrading system" >> failed.txt
                return 1
        fi
        echo "System updated!"
    fi
    if [[ "$system" == "Debian" ]]; then
        if ! sudo apt update; then
                echo "Updating system" >> failed.txt
                return 1
        fi
        if ! sudo apt upgrade -y; then
                echo "Upgrading system" >> failed.txt
                return 1
        fi
        echo "System updated!"
    fi
}

function install_gnome_apps(){
    if [[ "$XDG_CURRENT_DESKTOP" =~ "GNOME" ]]; then
        if ! flatpak install flathub com.mattjakeman.ExtensionManager -y; then
                echo "Installing Gnome Extensions" >> failed.txt
                return 1
        fi
        if [[ "$system" == "Fedora" ]]; then
            if ! sudo dnf install gnome-tweaks -y; then
                    echo "Installing Gnome Tweaks" >> failed.txt
                    return 1
            fi
        fi
        if [[ "$system" == "Debian" ]]; then
            if ! sudo apt install gnome-tweaks -y; then
                    echo "Installing Gnome Tweaks" >> failed.txt
                    return 1
            fi
        fi
    fi
}

update_system
set_up_flatpak

if [[ "$basic" == "y" ]]; then
    install_codecs
    install_git
    post_install_setup
    install_gnome_apps
fi

if [[ "$tools" == "y" ]]; then
    install_gimp
    install_grubcostum
    install_fish
    install_vscode
    install_libre_office
    install_obsidian
    install_keepassxc
    install_transmission
    install_shotcut
    install_neofetch
    install_kitty
fi

if [[ "$gaming" == "y" ]]; then
    install_steam
    install_protonge
    install_discord
    install_modrinth
    install_retroarch
    install_openrgb
    install_mangohud
fi

echo "Installation complete!"

if [[ -f "$directory/failed.txt" ]]; then
    echo "Failed installations:"
    cat "$directory/failed.txt"
    rm "$directory/failed.txt"b
else
    echo "No failed installations."
fi

echo "Restart computer  to apply changes y/n?"
read restart
if [[ "$restart" == "y" ]]; then
    echo "Restarting computer..."
    for ((i=5; i>=1; i--)); do
        echo "Restarting in $i seconds..."
        sleep 1
    done
    echo "Restarting computer..."
    sudo reboot now
fi
if [[ "$restart" == "n" ]]; then
    echo "Restart your computer after you finish your work."
fi
