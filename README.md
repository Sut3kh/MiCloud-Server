### Encrypt backups

```sh
# Go super-saiyan.
sudo -i

# find drive
fdisk -l

# encrypt
yum install -y cryptsetup-luks
cryptsetup --verify-passphrase luksFormat /dev/sdc -c aes -s 256 -h sha256

# decrypt and format
cryptsetup luksOpen /dev/sdc securebackups
mkfs -t ext4 -m 1 /dev/mapper/securebackups

# mount
mkdir -p /backups
mount /dev/mapper/securebackups /backups
```

### Install dropbox

- `cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -`
- `sudo wget -O /usr/local/bin/dropbox https://www.dropbox.com/download?dl=packages/dropbox.py && sudo chmod +x /usr/local/bin/dropbox`
- `~/.dropbox-dist/dropboxd`

### Install backup service (on client).

- `sudo systemctl enable $(pwd)/backup.service $(pwd)/backup.timer`
- `sudo systemctl start backup.timer`
