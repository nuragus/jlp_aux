# prereqs
sudo apt update
sudo apt install -y wget build-essential libreadline-dev

# download sources
if [ $1 == "mirror_local" ] then
  wget https://mirror.virkea.com/zlib-1.2.11.tar.gz
  wget https://mirror.virkea.com/uuid-1.6.2.tar.gz
  wget https://mirror.virkea.com/uuid-1.6.2.tar.gz
  wget https://mirror.virkea.com/postgresql-9.6.1.tar.gz
else
  wget http://www.zlib.net/zlib-1.2.11.tar.gz
  wget http://www.mirrorservice.org/sites/ftp.ossp.org/pkg/lib/uuid/uuid-1.6.2.tar.gz
  wget https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.5.1.tar.gz
  wget https://ftp.postgresql.org/pub/source/v9.6.1/postgresql-9.6.1.tar.bz2
fi

# compile zlib
tar -xzf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure && make -j 4 && sudo make install
cd ..

# compile uuid
tar -xzf uuid-1.6.2.tar.gz
cd uuid-1.6.2
./configure && make -j 4 && sudo make install
cd ..

# compile libressl
tar -xzf libressl-2.5.1.tar.gz
cd libressl-2.5.1
./configure && make -j 4 && sudo make install
cd ..

# link libraries
sudo ln -s /usr/local/lib/libcrypto.so /usr/lib/libcrypto.so.41
sudo ln -s /usr/local/lib/libssl.so /usr/lib/libssl.so.43
sudo ln -s /usr/local/lib/libuuid.so /usr/lib/libuuid.so
sudo ln -s /usr/local/lib/libuuid.so /usr/lib/libuuid.so.16

# compile postgres
bzip2 -d postgresql-9.6.1.tar.bz2
tar -xf postgresql-9.6.1.tar
cd postgresql-9.6.1
./configure --with-ossp-uuid --with-openssl
make -j 4
sudo make install
cd ..

# create user
sudo useradd postgres -m -d /home/postgres -s /bin/bash -U

# set environment
sudo touch /home/postgres/.bash_profile
sudo chmod o+w /home/postgres/.bash_profile
sudo echo "export PATH=/usr/local/pgsql/bin:$PATH" >> /home/postgres/.bash_profile
sudo echo "export PGDATA=/usr/local/pgsql/data" >> /home/postgres/.bash_profile
sudo echo "export PGDATABASE=postgres" >> /home/postgres/.bash_profile
sudo echo "export PGUSER=postgres" >> /home/postgres/.bash_profile
sudo echo "export PGPORT=5432" >> /home/postgres/.bash_profile
sudo echo "export PGLOCALEDIR=/usr/local/pgsql/share/locale" >> /home/postgres/.bash_profile
sudo echo "export MANPATH=$MANPATH:/usr/local/pgsql/share/man" >> /home/postgres/.bash_profile
sudo echo "alias pgstart='pg_ctl -D /usr/local/pgsql/data start'" >> /home/postgres/.bash_profile
sudo echo "alias pgstop='pg_ctl -D /usr/local/pgsql/data stop'" >> /home/postgres/.bash_profile
sudo echo "alias pgreload='pg_ctl -D /usr/local/pgsql/data reload'" >> /home/postgres/.bash_profile
sudo echo "alias cddd='cd /usr/local/pgsql/data '" >> /home/postgres/.bash_profile

# create data directory
sudo mkdir /usr/local/pgsql/data
sudo chown -R postgres:postgres /usr/local/pgsql/data

# initialize data
sudo su - postgres -c "initdb"

# start postgres
sudo su - postgres -c "pg_ctl -D /usr/local/pgsql/data start"

# stop postgres
sudo su - postgres -c "pg_ctl -D /usr/local/pgsql/data stop"

