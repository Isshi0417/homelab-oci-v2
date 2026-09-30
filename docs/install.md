# Installing the host

## 1. Build the ISO (on your laptop, not in the dev container)
```bash
cp os/host/install/install.env.example os/host/install/install.env
$EDITOR os/host/install/install.env   # hash: openssl passwd -6
make iso
```

## 2. Write it to a USB stick
```bash
lsblk   # find the USB device
sudo dd if=output/bootiso/install.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 3. BIOS settings on the P3
- SVM (AMD-V) virtualization: **enabled**
- Restore on AC power loss: **power on**
- Boot from the USB stick

The install is **unattended and wipes `INSTALL_DISK`**. It reboots when done.

## 4. First boot
```bash
ssh sho@<p3-ip>
nmcli -f NAME,DEVICE,STATE connection
sudo bootc status
```

Add a DHCP reservation for the P3 on your router.

## 5. Turn on signature enforcement
```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/isshi0417/homelab-host:latest
sudo bootc status --format yaml | grep -A2 signature
sudo systemctl reboot
```
