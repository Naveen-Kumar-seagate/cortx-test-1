#!/bin/sh
secrets_json_path=/root/secrets.json
cp $secrets_json_path "$WORKSPACE/cortx-test/secrets.json"
cd cortx-test

FILE=$WORKSPACE/prov_config.ini
if [ -f "$FILE" ]; then
    echo "$FILE exists."
    cp "$WORKSPACE/prov_config.ini" "$WORKSPACE/cortx-test/prov_config.ini"
else
    echo "$FILE does not exist."
fi

function check_installation {
  pckarr=(unzip, google-chrome-stable_current_x86_64.rpm )
  for i in  ${pckarr[*]}
   do
   isinstalled=$(rpm -q $i)
   if [ !  "$isinstalled" == "package $i is not installed" ];
   then
     echo Package  $i already installed
   else
     echo $i is not installed!
     yum install -y $i
   fi
   done
}

#yum update -y
yum install -y nfs-utils

mkdir -p /etc/ssl/stx-s3-clients/s3/
cp ci_tools/ca.crt /etc/ssl/stx-s3-clients/s3/


yum install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make sqlite-devel
if [[ ! -f "/usr/bin/python3.7" ]]
then
  cd /usr/src && wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && tar xzf Python-3.7.9.tgz && rm -f Python-3.7.9.tgz
  cd /usr/src/Python-3.7.9 && ./configure --prefix=/usr --enable-optimizations
  cd /usr/src/Python-3.7.9 && make altinstall
  echo 'alias python3="/usr/bin/python3.7"' >> ~/.bashrc
fi

yum install -y python3-devel librdkafka python3-tkinter

python3.7 -m venv virenv
source virenv/bin/activate
pip install --upgrade pip
if ${Need_pip_source}; then
pip3 install -r requirements.txt -i https://pypi.python.org/simple/
else
pip3 install -r requirements.txt
fi
export PYTHONPATH=$WORKSPACE:$WORKSPACE/cortx-test:$PYTHONPATH


cd "$WORKSPACE/cortx-test/scripts/s3_tools/"
make clean
make install-tools

cd "$WORKSPACE/cortx-test/"

wget -N https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

check_installation

if [[ -f "/usr/bin/google-chrome" ]]
then
  wget -N https://chromedriver.storage.googleapis.com/91.0.4472.19/chromedriver_linux64.zip
  unzip chromedriver_linux64.zip
  chmod 777 chromedriver
  mv chromedriver $WORKSPACE/cortx-test/virenv/bin
fi