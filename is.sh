#!/bin/bash

export LC_ALL=C

#Paketi / Packages
sudo pacman -Syyu

sudo pacman -S --noconfirm lib32-mesa mesa-demos

sudo pacman -S --noconfirm ufw ffmpegthumbnailer gst-libav gst-plugins-base gst-plugins-good gtk-engine-murrine ntfs-3g gksu qt4 p7zip unrar qt5ct youtube-dl mpv file-roller xorg-fonts-type1 acpid dosfstools gparted plank ttf-freefont ttf-dejavu ttf-sazanami ttf-fireflysung noto-fonts-emoji ttf-symbola xorg-xlsfonts dnsmasq qt5-styleplugins clementine transmission-gtk firefox firefox-i18n-sr obs-studio wine-staging-nine chromium snes9x-gtk dolphin-emu nestopia pcsxr

sudo pacman -S --noconfirm lib32-libpulse lib32-openal lib32-gnutls lib32-mpg123 lib32-libxml2 lib32-lcms2 lib32-giflib lib32-libpng lib32-alsa-lib lib32-alsa-plugins lib32-nss lib32-gtk2 lib32-gtk3 lib32-libcanberra lib32-gconf lib32-dbus-glib lib32-libnm-glib lib32-libudev0-shim libpng12 lib32-libpng12 lib32-libcurl-gnutls lib32-libcurl-compat lib32-libstdc++5 lib32-libxv lib32-ncurses lib32-sdl lib32-zlib lib32-libgcrypt lib32-libgcrypt15

#fstab kačenje uređaja "sdxy" / fstab automount of device "sdxy"
echo "/dev/sdb1               /media/sdb1     ext4            defaults                        0 2" | sudo tee -a /etc/fstab

#Okruženje / Environment (mutter/clutter vblank disabled for GNOME based DE's)
echo "#CLUTTER_DEFAULT_FPS=120
CLUTTER_VBLANK=none
QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment

#Virtuelna memorija (podrazumevano "60") / Virtual memory (default "60")
echo "vm.swappiness=0" | sudo tee /etc/sysctl.d/99-sysctl.conf

#AUR
echo "[archlinuxfr]
SigLevel = Optional TrustedOnly
Server = http://repo.archlinux.fr/\$arch" | sudo tee -a /etc/pacman.conf

#Broj jezgara za AUR (-j3 = 2 jezgra) / Number of cores for AUR (-j3 = 2 cores)
sudo sed -i -e 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j5"/g' /etc/makepkg.conf
sudo sed -i -e 's/#PACKAGER="John Doe <john@doe.com>"/PACKAGER="lpr1"/g' /etc/makepkg.conf

#Sinhronizacija i instalacija "yaourt" paketa / Synchronization and installation of "yaourt" package
sudo pacman -Syy
sudo pacman -S --noconfirm yaourt

#Rezervisan EXT4 prostor / Reserved EXT4 space
sudo tune2fs -m 0 /dev/sda2
sudo tune2fs -m 0 /dev/sdb1

#Omogući TRIM podršku / Enable TRIM support
sudo systemctl enable fstrim.timer

#GDM onemogući "wayland" / GDM disable "wayland"
sudo sed -i -e 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm/custom.conf

#Zaštitni zid / Uncomplicated firewall
sudo ufw default deny
sudo ufw allow SSH
sudo ufw allow transmision
sudo ufw enable
sudo systemctl enable ufw

#DNS mrežna podešavanja / DNS network settings (systemd)
echo "[main]
dns=systemd-resolved" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl enable systemd-networkd.service
sudo systemctl enable systemd-resolved.service

#Tiho pokretanje / Silent boot 
sudo sed -i -e 's/ fsck//g' /etc/mkinitcpio.conf
sudo mkinitcpio -p linux
sudo sed -i -e 's/#GRUB_HIDDEN_TIMEOUT=5/GRUB_HIDDEN_TIMEOUT=1/g' /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
sudo sed -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 udev.log-priority=3 vt.global_cursor_default=0"/g' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo sed -i -e 's/echo/#echo/g' /boot/grub/grub.cfg
#Systemd fsck
sudo cp /usr/lib/systemd/system/systemd-fsck-root.service /etc/systemd/system/
sudo cp /usr/lib/systemd/system/systemd-fsck@.service /etc/systemd/system/
fsckrsd='/etc/systemd/system/systemd-fsck-root.service'
fsckd='/etc/systemd/system/systemd-fsck@.service'
nfsckrl='ExecStart=/usr/lib/systemd/systemd-fsck\
StandardOutput=null\
StandardError=journal+console'
nfsckl='ExecStart=/usr/lib/systemd/systemd-fsck %f\
StandardOutput=null\
StandardError=journal+console'
sudo sed -i "s|ExecStart=/usr/lib/systemd/systemd-fsck|$nfsckrl|g" $fsckrsd
sudo sed -i "s|ExecStart=/usr/lib/systemd/systemd-fsck %f|$nfsckl|g" $fsckd

#Uklanjanje nepotrebnih paketa / Removal of unnecassary packages
sudo pacman -Rsn --noconfirm gnome-2048 aisleriot atomix gnome-chess five-or-more hitori iagno gnome-klotski lightsoff gnome-mahjongg gnome-mines gnome-nibbles quadrapassel four-in-a-row gnome-robots gnome-sudoku swell-foop tali gnome-taquin gnome-tetravex anjuta

#AUR paketi / AUR packages
yaourt -S --noconfirm gnome-mpv
yaourt -S --noconfirm joystickwake-git
yaourt -S --noconfirm neofetch
yaourt -S --noconfirm numix-circle-icon-theme-git
yaourt -S --noconfirm adg-gtk-theme
yaourt -S --noconfirm numix-folders-git
yaourt -S --noconfirm gnome-terminal-csd1

#Za gnome-terminal-csd1 / For gnome-terminal-csd1
cd /tmp/yaourt-tmp-$USER
yes | sudo pacman -U gnome-terminal-csd1-*.pkg.tar.xz

#Numix-Folders
echo "6
grey
bdbdbd
757575
7f7f7f" > ~/.config/numix-folders

sudo numix-folders -p -t
sudo pacman -Rs --noconfirm numix-folders-git

#Gašenje vertikalne sinhronizacije / Disabling vertical synchronization
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

#GNOM 3 podešavanja / GNOME 3 specific setings
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/Waterfalls.jpg'
gsettings set org.gnome.desktop.interface clock-show-date 'true'
gsettings set org.gnome.desktop.interface gtk-theme 'AdG-Light'
gsettings set org.gnome.desktop.interface icon-theme 'Numix-Circle-Light'
gsettings set org.gnome.desktop.media-handling autorun-never 'true'
gsettings set org.gnome.desktop.privacy remember-recent-files 'false'
gsettings set org.gnome.desktop.screensaver lock-enabled 'false'
gsettings set org.gnome.desktop.search-providers disable-external 'true'
gsettings set org.gnome.desktop.session idle-delay '900'
gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar 'none'
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.gnome-system-monitor current-tab 'resources'
gsettings set org.gnome.Epiphany homepage-url 'about:blank'
gsettings set org.gnome.Epiphany restore-session-policy 'crashed'
gsettings set org.gnome.mutter center-new-windows 'true'
gsettings set org.gnome.nautilus.preferences automatic-decompression 'false'
gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
gsettings set org.gnome.nautilus.window-state geometry '834x560+548+230'
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar 'false'
gsettings set org.gnome.settings-daemon.peripherals.keyboard numlock-state 'on'
gsettings set org.gnome.shell enabled-extensions "['alternate-tab@gnome-shell-extensions.gcampax.github.com', 'apps-menu@gnome-shell-extensions.gcampax.github.com', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
gsettings set org.gnome.shell.extensions.user-theme name 'AdG-Light'
gsettings set org.gtk.Settings.FileChooser sort-directories-first 'true'
gsettings set org.gtk.Settings.FileChooser sidebar-width '173'
gsettings set org.gtk.Settings.FileChooser window-position '(245, 157)'
gsettings set org.gtk.Settings.FileChooser window-size '(791, 597)'
gconftool-2 --type string --set /apps/metacity/general/action_middle_click_titlebar 'none'

#Terminal/bashrc
echo "#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ \$- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\[\e[1;32m\]\u@\h\[\e[0m\]\[\e[0;34m\] \W\[\e[0m\]]\\$ '

neofetch" > ~/.bashrc

#MPV podešavanja / MPV settings
mkdir ~/.mpv
echo "# Set language.
slang=sr,en,eng

# Change subtitle encoding. For Arabic subtitles use 'cp1256'.
# If the file seems to be valid UTF-8, prefer UTF-8.
sub-codepage=utf8:cp1250
#sub-codepage=iso8859-15
loop-playlist=inf
vo=x11
#hwdec=vaapi" > ~/.mpv/mpv.conf
echo "MOUSE_BTN3 add volume 5
MOUSE_BTN4 add volume -5" > ~/.mpv/input.conf
gsettings set io.github.GnomeMpv mpv-config-enable 'true'
gsettings set io.github.GnomeMpv mpv-config-file ~/.mpv/mpv.conf
gsettings set io.github.GnomeMpv mpv-input-config-enable 'true'
gsettings set io.github.GnomeMpv mpv-input-config-file ~/.mpv/input.conf

#Gašenje skripta / Shutdown script
mkdir ~/.skripte
echo "#!/bin/bash
sudo shutdown -h +90
exec \$SHELL" > ~/.skripte/gasi.sh
chmod +x ~/.skripte/gasi.sh
echo "[Desktop Entry]
Name=Shutdown
Exec=gnome-terminal -e /home/simx/.skripte/gasi.sh
Icon=/home/simx/Слике/Ikonice/system-config-boot.svg
Type=Application" > ~/.local/share/applications/shutdown.desktop

unset LC_ALL

exit 0
