# Instalar WP CLI
remote_file '/tmp/wp' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Mover WP CLI a /bin
execute 'Move WP CLI' do
  command 'mv /tmp/wp /bin/wp'
  not_if { ::File.exist?('/bin/wp') }
end

# Hacer WP CLI ejecutable
file '/bin/wp' do
  mode '0755'
end

package 'unzip' do
  action :install
end
# Descargar el paquete de idioma español para WordPress
remote_file '/tmp/es_ES.zip' do
  source 'https://downloads.wordpress.org/translation/core/6.4.3/es_ES.zip'
  owner 'root'
  group 'root'
  mode '0777'
  action :create
  notifies :run, 'execute[extraer_paquete_espanol]', :immediately
end


# Extraer el paquete de idioma español
execute 'extraer_paquete_espanol' do
  command 'unzip /tmp/es_ES.zip -d /opt/wordpress/wp-content/languages/'
  action :nothing
  #action :run
end


# Instalar Wordpress y configurar
execute 'Finish Wordpress installation' do
  command "sudo -u vagrant -i -- wp core install --path=/opt/wordpress/ --url=http://192.168.56.10 --title=\"EPNEWMAN - Tarea Alejandro Patache\" --admin_user=admin --admin_password=\"Epnewman123\" --admin_email=admin@epnewman.edu.pe --locale=es_ES"
  not_if 'wp core is-installed', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end
execute 'Descargar WordPress en español' do
  command 'wp core download --locale=es_ES --path=/opt/wordpress/ --skip-content'
  not_if 'test -d /opt/wordpress/wp-admin'
end
# Instalar idioma español de WordPress
execute 'Instalar idioma español de WordPress' do
  command 'sudo -u vagrant -i -- wp site switch-language es_ES --path=/opt/wordpress/'
  not_if 'sudo -u vagrant -i -- wp language core is-installed es_ES --path=/opt/wordpress/', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end

