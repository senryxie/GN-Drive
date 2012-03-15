from time import sleep
from fabric.api import sudo, cd, env, run, settings

env.hosts=['ofshellohicy@gundam00']

def restart_mysql():
    sudo('/etc/init.d/mysql restart', user='root')

def restart_php():
    sudo('/etc/init.d/php-fastcgi restart', user='root')

def restart_nginx():
    sudo('/etc/init.d/nginx restart', user='root')

def update_drive():
    with cd('/home/nginx/GN-Drive'):
        sudo('git fetch origin',user='nginx')
        sudo('git rebase origin/master',user='nginx')
        sudo("find . -name '*.pyc' -delete", user='nginx')
    sudo('/etc/init.d/snap-fastcgi restart',user='root')

def see_letter():
    with cd('/home/nginx/'):
        run('cat dead.letter')
