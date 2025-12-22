FROM ubuntu:18.04
LABEL release_time="2023-05-04"
LABEL crypto_scout_version="v2.0"
WORKDIR /usr/bin
COPY tools/evm evm
WORKDIR /crypto_scout
COPY bin bin
COPY run.sh run.sh
COPY plugin.sh plugin.sh
COPY plugin plugin
COPY ethereum.7z ethereum.7z

RUN mkdir /usr/local/java
RUN mkdir /clib


RUN set -eux ;\
sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list ;\
sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list ;\
apt update -y && apt upgrade -y ;\
apt-get install openjdk-8-jdk -y;\
apt install -y curl wget vim sudo git python python-pip python3 python3-pip ;\
python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip ;\
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple ;\
pip install z3==0.2.0 ;\
pip install z3-solver==4.5.1.0 ;\
pip3 install openpyxl;\
pip3 install pandas;\
chmod +x plugin.sh ;\
chmod +x run.sh ;\
sudo apt autoremove -y ;\
sudo apt clean -y ;\
rm -rf /var/lib/apt/lists/* 
CMD [ "sh" , "-c" , "/crypto_scout/run.sh" ]
