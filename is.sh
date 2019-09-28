#!/bin/bash

export LC_ALL=C

#Updates / Ažuriranja
sudo pacman -Syyu
#Mesa (Open Source drivers, enable and change if needed)
sudo pacman -S --noconfirm lib32-mesa mesa-demos libva-mesa-driver glu lib32-glu opencl-mesa
#Packages / Paketi
sudo pacman -S --noconfirm git ufw ffmpegthumbnailer gst-libav gst-plugins-base gst-plugins-good gtk-engine-murrine ntfs-3g p7zip unrar qt5ct youtube-dl mpv file-roller xorg-fonts-type1 acpid dosfstools gparted plank ttf-freefont ttf-dejavu ttf-sazanami ttf-fireflysung noto-fonts-emoji xorg-xlsfonts qt5-styleplugins transmission-gtk firefox firefox-i18n-sr chromium obs-studio wine-staging wine-nine materia-gtk-theme
sudo pacman -S --noconfirm lib32-libpulse lib32-openal lib32-gnutls lib32-mpg123 lib32-libxml2 lib32-lcms2 lib32-giflib lib32-libpng lib32-alsa-lib lib32-alsa-plugins lib32-nss lib32-gtk2 lib32-gtk3 lib32-libcanberra lib32-dbus-glib lib32-libnm-glib lib32-libudev0-shim libpng12 lib32-libpng12 lib32-libcurl-gnutls lib32-libcurl-compat lib32-libxv lib32-ncurses lib32-sdl lib32-zlib lib32-libgcrypt lib32-libgcrypt15

#fstab automount of device "sdxy" (enable-change for your device) / fstab kačenje uređaja "sdxy"
#echo "/dev/sdb1               /media/sdb1     ext4            defaults                        0 2" | sudo tee -a /etc/fstab

#Environment (mutter/clutter vblank disabled for GNOME based DE's) / Okruženje
echo "#CLUTTER_DEFAULT_FPS=120
#CLUTTER_PAINT=disable-clipped-redraws:disable-culling
#R600_DEBUG=nodma
#MESA_GL_VERSION_OVERRIDE=4.5
#MESA_GLSL_VERSION_OVERRIDE=450
CLUTTER_VBLANK=none
QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

#X.Org (NOT NEEDED ANYMORE)
#echo 'Section "Device"
#	Identifier "Radeon"
#	Driver "radeon"
#	Option "AccelMethod" "exa"
#	Option "TearFree" "on"
#	Option "DRI" "2"
#EndSection' | sudo tee /etc/X11/xorg.conf.d/20-radeon.conf

#Virtual memory (default "60", "0" = disabled) / Virtuelna memorija (podrazumevano "60")
#echo "vm.swappiness=0" | sudo tee /etc/sysctl.d/99-sysctl.conf

#Number of cores for AUR (-j3 = 2 cores) / Broj jezgara za AUR (-j3 = 2 jezgra)
#Change "-j5" to your number of cores + 1
sudo sed -i -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j5"/g' /etc/makepkg.conf
sudo sed -i -e 's/#PACKAGER="John Doe <john@doe.com>"/PACKAGER="lpr1"/g' /etc/makepkg.conf

#AUR: Installation of "yay" package / Instalacija "yay" paketa
git clone https://aur.archlinux.org/yay.git
cd ./yay
makepkg -sic --noconfirm

#Reserved EXT4 space / Rezervisan EXT4 prostor
#sudo tune2fs -m 0 /dev/sda2
#sudo tune2fs -m 0 /dev/sdb1

#Enable TRIM support / Omogući TRIM podršku
sudo systemctl enable fstrim.timer

#GDM onemogući "wayland" / GDM disable "wayland"
#sudo sed -i -e 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm/custom.conf

#Uncomplicated firewall / Zaštitni zid
sudo ufw default deny
sudo ufw allow SSH
sudo ufw allow transmision
sudo ufw enable
sudo systemctl enable ufw

#DNS network settings (systemd) / DNS mrežna podešavanja
echo "[main]
dns=systemd-resolved" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl enable systemd-networkd.service
sudo systemctl enable systemd-resolved.service

#Silent boot / Tiho pokretanje
sudo sed -i -e 's/ fsck//g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
sudo sed -i -e 's/#GRUB_HIDDEN_TIMEOUT=5/GRUB_HIDDEN_TIMEOUT=1/g' /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 udev.log-priority=3 vt.global_cursor_default=0"/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sed -i -e 's/echo/#echo/g' /boot/grub/grub.cfg

#Systemd fsck (ONLY FOR SYSTEMD BOOT)
#sudo cp /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/
#sudo cp /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/
#fsckrsd='/etc/systemd/system/systemd-fsck-root.service'
#fsckd='/etc/systemd/system/systemd-fsck@.service'
#nfsckrl='ExecStart=/usr/lib/systemd/systemd-fsck\
#StandardOutput=null\
#StandardError=journal+console'
#nfsckl='ExecStart=/usr/lib/systemd/systemd-fsck %f\
#StandardOutput=null\
#StandardError=journal+console'
#sudo sed -i "s|ExecStart=/usr/lib/systemd/systemd-fsck|$nfsckrl|g" $fsckrsd
#sudo sed -i "s|ExecStart=/usr/lib/systemd/systemd-fsck %f|$nfsckl|g" $fsckd

#Removal of unnecassary packages / Uklanjanje nepotrebnih paketa
sudo pacman -Rsn --noconfirm gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex

#AUR packages / AUR paketi
yay -S --noconfirm joystickwake-git
yay -S --noconfirm neofetch
yay -S --noconfirm numix-icon-theme-git
yay -S --noconfirm numix-circle-icon-theme-git
yay -S --noconfirm numix-folders-git

#For gnome-terminal-csd1 / Za gnome-terminal-csd1
#cd /tmp/trizen-$USER/gnome-terminal-csd1/
#yes | sudo pacman -U gnome-terminal-csd1-*.pkg.tar.xz

#Numix-Folders
echo "6
grey
bdbdbd
757575
7f7f7f" > ~/.config/numix-folders

sudo numix-folders -p -t
sudo pacman -Rs --noconfirm numix-folders-git

#Disabling vertical synchronization / Gašenje vertikalne sinhronizacije
echo '<driconf>
    <device screen="0" driver="dri2">
        <application name="Default">
            <option name="vblank_mode" value="0" />
        </application>
        <application name="chromium">
            <option name="vblank_mode" value="1" />
        </application>
    </device>
</driconf>' > ~/.drirc

#GNOME 3 specific setings / GNOM 3 podešavanja
gsettings set org.gnome.desktop.interface clock-show-date 'true'
gsettings set org.gnome.desktop.interface gtk-theme 'Materia-light'
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle'
gsettings set org.gnome.desktop.media-handling autorun-never 'true'
gsettings set org.gnome.desktop.privacy remember-recent-files 'false'
gsettings set org.gnome.desktop.screensaver lock-enabled 'false'
gsettings set org.gnome.desktop.search-providers disable-external 'true'
gsettings set org.gnome.desktop.session idle-delay '1200'
gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar 'none'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.Epiphany homepage-url 'about:blank'
gsettings set org.gnome.Epiphany restore-session-policy 'crashed'
gsettings set org.gnome.gnome-system-monitor current-tab 'resources'
gsettings set org.gnome.mutter center-new-windows 'true'
gsettings set org.gnome.nautilus.window-state sidebar-width '190'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gnome.nautilus.window-state initial-size '(848, 586)'
gsettings set org.gnome.desktop.peripherals.keyboard remember-numlock-state 'true'
gsettings set org.gnome.desktop.peripherals.keyboard numlock-state 'true'
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar 'false'
gsettings set org.gnome.shell enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com','user-theme@gnome-shell-extensions.gcampax.github.com']"
gsettings set org.gnome.shell.extensions.user-theme name 'Materia-light'
gsettings set org.gtk.Settings.FileChooser sidebar-width '190'
gsettings set org.gtk.Settings.FileChooser sort-directories-first 'true'
gsettings set org.gtk.Settings.FileChooser window-position '(574, 231)'
gsettings set org.gtk.Settings.FileChooser window-size '(773, 570)'

#Terminal/bashrc
echo "#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ \$- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\[\e[1;32m\]\u@\h\[\e[0m\]\[\e[0;34m\] \W\[\e[0m\]]\\$ '

neofetch" > ~/.bashrc

#MPV settings / MPV podešavanja
mkdir ~/.mpv
echo "# Set language.
slang=sr,en,eng

# Change subtitle encoding. For Arabic subtitles use 'cp1256'.
# If the file seems to be valid UTF-8, prefer UTF-8.
sub-codepage=utf8:cp1250
#sub-codepage=utf8:cp1251
loop-playlist=inf
vo=xv
hwdec=vaapi
#mute=yes" > ~/.mpv/mpv.conf
echo "MOUSE_BTN3 add volume 5
MOUSE_BTN4 add volume -5" > ~/.mpv/input.conf

#Shutdown script / Gašenje skripta
#mkdir ~/.skripte
#echo "#!/bin/bash
#sudo shutdown -h +120
#exec \$SHELL" > ~/.skripte/gasi.sh
#chmod +x ~/.skripte/gasi.sh
#echo "[Desktop Entry]
#Name=Shutdown
#Exec=gnome-terminal -e /home/simx/.skripte/gasi.sh
#Icon=/home/simx/Слике/Ikonice/system-config-boot.svg
#Type=Application" > ~/.local/share/applications/shutdown.desktop

unset LC_ALL

exit 0
