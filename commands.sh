# steps:
# -- create azure vm
# edit sshd_conf
StrictMOdes no
PasswordAuthentication yes
UserLogin yes

# change password agus
sudo passwd agus

sudo apt update
sudo apt install lxc lxc-common

sudo lxc-create -n pg_pkg -t ubuntu

