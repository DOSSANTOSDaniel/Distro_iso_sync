# Distro_iso_sync
Téléchargement et mise à jour d'images ISO's des principales distributions Linux et de FreeBSD.

## Description
C'est un script non interactif,il permet : 
- Télécharger les images ISOs des principales distributions Linux. 
- Tester et valider l'accessibilité au site de téléchargement de la distribution.
- Mettre à jour quand une nouvelle image ISO est disponible.
- La mise en place de la journalisation des erreurs.

## Afficher l'avancement du téléchargement
```Bash
watch -n 1 -d 'du -h $HOME/Isos/*'
```

```
Every 1.0s: du -h $HOME/Isos/*
11G     Isos/AlmaLinux-9-latest-x86_64-dvd.iso
2.2G    Isos/Fedora-Workstation-Live-x86_64-40-1.14.iso
4.3G    Isos/FreeBSD-14.1-RELEASE-amd64-dvd1.iso
1.1G    Isos/Rocky-9-latest-x86_64-dvd.iso
1.1G    Isos/archlinux-x86_64.iso
3.8G    Isos/debian-12.6.0-amd64-DVD-1.iso
4.1G    Isos/kali-linux-2024.1-live-amd64.iso
2.9G    Isos/linuxmint-21.3-cinnamon-64bit.iso
4.2G    Isos/openSUSE-Leap-15.5-DVD-x86_64-Media.iso
1.4G    Isos/proxmox-ve_8.2-1.iso
5.7G    Isos/ubuntu-24.04-desktop-amd64.iso
2.6G    Isos/ubuntu-24.04-live-server-amd64.iso
```
## Afficher les logs
```
cat /var/log/syslog | grep 'distro_iso_sync'

journalctl
```
## Reste à faire
- [ ] Détecter les images ISO's trop anciennes et les supprimer.
