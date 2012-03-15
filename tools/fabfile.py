from fabric.api import sudo, cd, env#, run

env.hosts=['ofshellohicy@gundam00']

def restart_mysql():
    sudo('sudo /etc/init.d/mysql restart', user='ofshellohicy')

def restart_php():
    sudo('sudo /etc/init.d/php-fastcgi restart', user='ofshellohicy')

def restart_nginx():
    sudo('sudo /etc/init.d/nginx restart', user='ofshellohicy')

def update_drive():
    with cd('/home/nginx/GN-Drive'):
        sudo('git fetch origin',user='nginx')
        sudo('git rebase origin/master',user='nginx')
        sudo('sudo /etc/init.d/snap-fastcgi restart',user='ofshellohicy')
