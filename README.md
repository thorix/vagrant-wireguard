# Vagrant with WireGuard

WireGuard uses kernel-level code that makes using Docker harder. In some cases, it might make more sense to use a VM in the name of isolation and security. This setup will create a VM using Libvirt and install Wiregaurd. Look in `provision.sh` to see what is being installed in the VM.

# Host setup (before this VM can run)
Before you can use this setup you will need vagrant [Vagrant](https://www.vagrantup.com/downloads.html)
You will also need to install Libvirt
```
sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin
sudo adduser $USER libvirt-qemu
sudo adduser $user libvirt
vagrant plugin install vagrant-libvirt
```

## Setting up Bridge network
Next, you will need to have a bridge network interface so the VM can attach.

/etc/network/interfaces
```
iface enp3s0 inet manual

auto br0
iface br0 inet static
  address  <ip.address>
  netmask  255.255.255.0
  broadcast <broadcast.mask>
  gateway  <ip.of.gateway>
  bridge_ports enp3s0
  bridge_maxwait 1
  bridge_stp on        # disable Spanning Tree Protocol
  bridge_waitport 0    # no delay before a port becomes available
  bridge_fd 0          # no forwarding delay
```

### do not query iptables for package routing
One last trick you might need is to enable network traffic to enter the bridge interface for the VM

```
echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptables
```

## Create a configuration file
BACKUP_SRC   location on the server to mount
BACKUP_DEST  Location in the VM to mount BACKUP_SRC too
BACKUP_USER  The user to add to the VM. Can be used for scp
SSH_KEY      The ssh public key of then given backup user

vi .vars
```
export BACKUP_SRC=/mnt/data/backup
export BACKUP_DEST=/backup
export BACKUP_USER=backupuser
export SSH_KEY=pub.key
```

## start the VM
```
source .vars
vagrant up
```

### Debug VM
Now you can login into the VM and look around
```
vagrant ssh
```

if everything is working you should see something like this:
```
vagrant@gauge:~$ /sbin/ifconfig wg0
wg0: flags=209<UP,POINTOPOINT,RUNNING,NOARP>  mtu 1420
        inet 10.100.10.1  netmask 255.255.255.0  destination 10.100.10.1
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 1  (UNSPEC)
        RX packets 9688  bytes 1093 (1.8 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 6351  bytes 4883 (4.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vagrant@gauge:~$ sudo wg show
interface: wg0
  public key: /AyKKgDqqqqnkQLmQQQQcHrqqqqwq6oxI6Wmc7gQ=
  private key: (hidden)
  listening port: 5555

peer: ay9QQQNR+qqqfqqdYfqsiyn83uR+krqkO3xpoT7zzg=
  endpoint: 1.2.3.4:5540
  allowed ips: 10.100.10.2/32
  latest handshake: 1 minute, 18 seconds ago
  transfer: 1.83 GiB received, 4.48 GiB sent

vagrant@gauge:~$ sudo wg showconf wg0
[Interface]
ListenPort = 5555
PrivateKey = OJWmP8TSQ2qqqqUn98QQQQo8aqqqkOrx4Rgai8Vc3Y=

[Peer]
PublicKey = ay9QQQNR+qqqfqqdYfqsiyn83uR+krqkO3xpoT7zzg
AllowedIPs = 10.100.10.2/32
Endpoint = 1.2.3.4:5540
```
