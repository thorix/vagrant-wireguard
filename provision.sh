while getopts ":u:k:h:" opt; do
    case "$opt" in
        u)
            backup_user="$OPTARG" ;;
        k)
            ssh_key="$OPTARG" ;;
    esac
done

# Fix locales: Cannot set LC_MESSAGES to default locale: No such file or directory
#sudo locale-gen --purge en_US.UTF-8
sudo sh -c "echo 'LANG=\"en_US.UTF-8\"\\nLANGUAGE=\"en_US:en\"\\n' > /etc/default/locale"
sudo sh -c "echo 'LC_ALL=en_US.UTF-8' >> /etc/environment"
sudo sh -c "echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen"
sudo sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
sudo locale-gen en_US.UTF-8

# Install wireguard
sudo sh -c "echo 'deb http://deb.debian.org/debian/ unstable main' > /etc/apt/sources.list.d/unstable-wireguard.list"
sudo sh -c " printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable"
sudo apt-get update
sudo apt-get -y install wireguard

# https://www.linode.com/docs/networking/vpn/set-up-wireguard-vpn-on-ubuntu/
sudo wg-quick up /vagrant/private/wg0.conf
sudo systemctl enable wg-quick@wg0

sudo apt-get install rssh
sudo sh -c "echo 'allowscp' >> /etc/rssh.conf"
sudo sh -c "echo 'allowsftp' >> /etc/rssh.conf"

sudo adduser \
   --system \
   --shell /usr/bin/rssh \
   --gecos 'User for scping backups' \
   --disabled-password \
   $backup_user

sudo mkdir /home/$backup_user/.ssh
sudo chmod 700 /home/$backup_user/.ssh
sudo cp /vagrant/private/$ssh_key /home/$backup_user/.ssh/authorized_keys
sudo chmod 600 /home/$backup_user/.ssh/authorized_keys
sudo chown -R chris /home/$backup_user/.ssh

