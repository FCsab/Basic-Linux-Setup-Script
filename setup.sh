#!/bin/bash
if [[ $(dnf --version) ]];
    then system="Fedora"
fi

if [[ "$system" != "Fedora" ]]; then
    echo "No support for you yet."
fi

echo "$system detected on your computer."

function install_steam(){
     if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm;
 then
      echo "Error installing RPMFusion repositories."
      echo "Steam" >> failed.txt
      return 1
    fi

    if ! sudo dnf config-manager --set-enabled fedora-cisco-openh264 -y; then
      echo "Error enabling fedora-cisco-openh264 repository."
      echo "Steam" >> failed.txt
      return 1
    fi

    if ! sudo dnf install -y steam; then
      echo "Error installing Steam."
      echo "Steam" >> failed.txt
      return 1
    fi
    echo "Steam installation successful!"
    fi
}

function post_install_setup(){
     if [[ "$system" == "Fedora" ]]; then
        if ! sudo echo "[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=1
max_parallel_downloads=10
deltarpm=true" > /etc/dnf/dnf.conf
then
    echo "Error during setting up dnf."
    echo "DNF config" >> failed.txt
    return 1
fi
}

function enable_bluetooth(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo systemctl enable --now bluetooth
            then
                echo "Error during starting Bluetooth."
                echo "Enabling bluetooth" >> failed.txt
                return 1
        fi
        echo "Bluetooth enabled!"
    fi
}

function install_codecs(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing -y
            then
                echo "Error during installing codecs."
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf update @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
            then
                echo "Error during installing codecs."
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf install ffmpeg ffmpeg-libs libva libva-utils -y
            then
                echo "Error during installing codecs."
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf config-manager --set-enabled fedora-cisco-openh264 -y
            then
                echo "Error during enabling repository."
                echo "codecs" >> failed.txt
                return 1
        fi
        if ! sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264 -y
            then
                echo "Error during installing codecs."
                echo "codecs" >> failed.txt
                return 1
        fi
    echo "Codecs installation successful!"
    fi
}

function install_protonge(){
    if [[ "$system" == "Fedora" ]]; then
        mkdir ~/.steam/root/compatibilitytools.d
            if ! wget -P ~/Downloads https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton9-11/GE-Proton9-11.tar.gz
                then
                    echo "Error during downloading ProtonGE."
                    echo "Installing ProtonGe" >> failed.txt
                    return 1
            fi
            if ! mkdir ~/.steam/root/compatibilitytools.d/
                then
                    echo "Error during creating directory."
                    echo "ProtonGe folder creation" >> failed.txt
                    return 1
            fi
            if ! tar -xf GE-Proton9-11.tar.gz -C ~/.steam/root/compatibilitytools.d/
                then
                    echo "Error during unpacking package."
                    echo "ProtonGe extract" >> failed.txt
                    return 1
            fi
            if ! rm ~/Downloads/GE-Proton9-11.tar.gz
                then
                    echo "Error during cleaning up."
                    echo "ProtonGe clean" >> failed.txt
                    return 1
            fi
    fi
}

function install_git(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install git -y
            then
                echo "Error during installing Git."
                echo "Installing git" >> failed.txt
                return 1
        fi
        if ! flatpak install flathub io.github.shiftey.Desktop
            then
                echo "Error during installing GitHub Desktop."
                echo "Installing GitHub Desktop" >> failed.txt
                return 1
        echo "Git installation successful!"
    fi
}

function install_discord(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            then
                echo "Error adding repo."
                echo "Adding Discord repo" >> failed.txt
                return 1
        fi
        if ! sudo dnf update -y
            then
                echo "Error during updating."
                echo "Updating for Discord" >> failed.txt
                return 1
        fi
        if ! sudo dnf install discord -y
            then
                echo "Error during installing Discord."
                echo "Installing Discord" >> failed.txt
                return 1
        fi
        echo "Discord installation successful!"
    fi
}

function install_grubcostum(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install grub-customizer -y
            then
                echo "Error during installing Grub Customizer."
                echo "Installing Grub Customizer" >> failed.txt
                return 1
        fi
        echo "Grub Customizer installation successful!"
    fi
}

function install_gimp(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install gimp -y
            then
                echo "Error during installing GIMP."
                echo "Installing GIMP" >> failed.txt
                return 1
        fi
        echo "GIMP installation successful!"
    fi
}

function install_fish(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install fish -y
            then
                echo "Error during installing Fish."
                echo "Installing Fish" >> failed.txt
                return 1
        fi
        if ! chsh -s /usr/bin/fish
            then
                echo "Error during changing shell."
                echo "Changing shell to Fish" >> failed.txt
                return 1
        fi
        echo "Fish installation successful!"
    fi
}

function install_vscode(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            then
                echo "Error during importing key."
                return 1
                echo "Importing key for Visual Studio Code" >> failed.txt
        fi
        if ! sudo dnf check-update
            then
                echo "Error during checking for updates."
                echo "Checking for updates for Visual Studio Code" >> failed.txt
                return 1
        fi
        if ! sudo dnf install code -y
            then
                echo "Error during installing Visual Studio Code."
                echo "Installing Visual Studio Code" >> failed.txt
                return 1
        fi
        echo "Visual Studio Code installation successful!"
    fi
}

function install_rust(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install rust -y
            then
                echo "Error during installing Rust."
                echo "Installing Rust" >> failed.txt
                return 1
        fi
        echo "Rust installation successful!"
    fi
}

function set_up_flatpak(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install flatpak -y
            then
                echo "Error during installing Flatpak."
                echo "Installing Flatpak" >> failed.txt
                return 1
        fi
        if ! flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            then
                echo "Error during adding Flathub."
                echo "Adding Flathub" >> failed.txt
                return 1
        fi
        echo "Flatpak installation successful!"
    fi
}

function install_libre_office(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install libreoffice -y
            then
                echo "Error during installing Libre Office."
                echo "Installing Libre Office" >> failed.txt
                return 1
        fi
        echo "Libre Office installation successful!"
    fi
}

function install_obsidian(){
    if [[ "$system" == "Fedora" ]]; then
        if ! flatpak install flathub md.obsidian.Obsidian -y
            then
                echo "Error during installing Obsidian."
                echo "Installing Obsidian" >> failed.txt
                return 1
        fi
        echo "Obsidian installation successful!"
    fi
}

function install_modrinth(){
    if [[ "$system" == "Fedora" ]]; then
        if ! flatpak install flathub com.modrinth.ModrinthApp -y
            then
                echo "Error during installing Modrinth."
                echo "Installing Modrinth" >> failed.txt
                return 1
        fi
        echo "Modrinth installation successful!"
    fi
}

function install_retroarch(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install retroarch -y
            then
                echo "Error during installing Retroarch."
                echo "Installing Retroarch" >> failed.txt
                return 1
        fi
        echo "Retroarch installation successful!"
    fi
}

function install_keepassxc(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install keepassxc -y
            then
                echo "Error during installing KeepassXC."
                echo "Installing KeepassXC" >> failed.txt
                return 1
        fi
        echo "KeepassXC installation successful!"
    fi
}

function install_transmission(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install transmission -y
            then
                echo "Error during installing transmission."
                echo "Installing Transmission" >> failed.txt
                return 1
        fi
        echo "Transmission installation successful!"
    fi
}

function install_shotcut(){
    if [[ "$system" == "Fedora" ]]; then
        if ! flatpak install flathub org.shotcut.Shotcut -y
            then
                echo "Error during installing Shotcut."
                echo "Installing Shotcut" >> failed.txt
                return 1
        fi
        echo "Shotcut installation successful!"
    fi
}

function install_neofetch(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install neofetch -y
            then
                echo "Error during installing Neofetch."
                echo "Installing Neofetch" >> failed.txt
                return 1
        fi
        echo "Neofetch installation successful!"
    fi
}

function install_openrgb(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install openrgb -y
            then
                echo "Error during installing OpenRGB."
                echo "Installing OpenRGB" >> failed.txt
                return 1
        fi
        echo "OpenRGB installation successful!"
    fi
}

function install_mangohud(){
    if [[ "$system" == "Fedora" ]]; then
        if ! sudo dnf install mangohud -y
            then
                echo "Error during installing MangoHud."
                echo "Installing MangoHud" >> failed.txt
                return 1
        fi
        echo "MangoHud installation successful!"
    fi
}

install_steam
install_codecs
install_git
enable_bluetooth
post_install_setup
install_discord
install_grubcostum
install_protonge
install_gimp
install_fish
install_vscode
install_rust
set_up_flatpak
install_libre_office
install_obsidian
install_modrinth
install_retroarch
install_keepassxc
install_transmission
install_shotcut
install_neofetch
install_openrgb
install_mangohud

echo "Installation complete!"
echo "Failed installations:"
echo cat failed.txt