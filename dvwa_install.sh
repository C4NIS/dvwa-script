#!/bin/bash

# Função para pedir confirmação antes de continuar
function prompt_continue() {
    read -p "Deseja continuar para a próxima etapa? (s/n): " choice
    case "$choice" in 
        s|S ) echo "Continuando...";;
        n|N ) echo "Saindo..."; exit 1;;
        * ) echo "Opção inválida."; prompt_continue;;
    esac
}

# Etapa 1: Atualizar o sistema
echo "Etapa 1: Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y
prompt_continue

# Etapa 2: Instalar Apache, MySQL e PHP
echo "Etapa 2: Instalando Apache, MySQL e PHP..."
sudo apt install apache2 mysql-server php php-mysqli php-gd libapache2-mod-php -y
prompt_continue

# Etapa 3: Configurar MySQL
echo "Etapa 3: Configurando MySQL..."
sudo mysql_secure_installation
prompt_continue

# Etapa 4: Criar banco de dados e usuário para DVWA
echo "Etapa 4: Criando banco de dados e usuário para DVWA..."
sudo mysql -u root -p -e "CREATE DATABASE dvwa;"
sudo mysql -u root -p -e "CREATE USER 'dvwa_user'@'localhost' IDENTIFIED BY 'dvwa_password';"
sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa_user'@'localhost';"
sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
prompt_continue

# Etapa 5: Baixar e configurar DVWA
echo "Etapa 5: Baixando e configurando DVWA..."
cd /var/www/html
sudo git clone https://github.com/digininja/DVWA.git
sudo chown -R www-data:www-data DVWA/
sudo chmod -R 755 DVWA/
cd DVWA/config
sudo cp config.inc.php.dist config.inc.php

# Modificar o arquivo de configuração
sudo sed -i "s/'database' => 'dvwa'/'database' => 'dvwa',/g" config.inc.php
sudo sed -i "s/'username' => 'root'/'username' => 'dvwa_user',/g" config.inc.php
sudo sed -i "s/'password' => ''/'password' => 'dvwa_password',/g" config.inc.php
prompt_continue

# Etapa 6: Configurar Apache para DVWA
echo "Etapa 6: Configurando Apache para DVWA..."
sudo tee /etc/apache2/sites-available/dvwa.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/DVWA
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

sudo a2ensite dvwa.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
prompt_continue

# Etapa 7: Finalizar instalação pelo navegador
echo "Etapa 7: Finalizando instalação pelo navegador..."
echo "Acesse http://<seu-ip>/DVWA para completar a instalação pelo navegador."

echo "Instalação completa!"
