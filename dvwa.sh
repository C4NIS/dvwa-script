#!/bin/bash

# Atualiza o sistema
sudo apt update -y
sudo apt upgrade -y

# Instala o Apache, MySQL e PHP
sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php php-gd php-xml php-mbstring -y

# Baixa e extrai o DVWA
cd /var/www/html
sudo wget https://github.com/digininja/DVWA/archive/master.zip
sudo apt install unzip -y
sudo unzip master.zip
sudo mv DVWA-master dvwa
sudo rm master.zip

# Permissões de diretório
sudo chown -R www-data:www-data /var/www/html/dvwa
sudo chmod -R 755 /var/www/html/dvwa

# Configurações do DVWA
cd /var/www/html/dvwa/config
sudo cp config.inc.php.dist config.inc.php

# Configurações do MySQL
sudo mysql -u root -e "CREATE DATABASE dvwa;"
sudo mysql -u root -e "CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"

# Edita o arquivo de configuração do DVWA
sudo sed -i "s/'db_password' => 'p@ssw0rd',/'db_password' => 'password',/" /var/www/html/dvwa/config/config.inc.php

# Reinicia o Apache
sudo systemctl restart apache2

# Instruções finais
echo "Instalação do DVWA concluída!"
echo "Por favor, abra o navegador e acesse http://localhost/dvwa para continuar a configuração."
