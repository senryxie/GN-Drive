from fabric.api import sudo, cd, env, run, get, put

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
    sudo('/etc/init.d/snap-drive restart',user='root')

def see_letter():
    with cd('/home/nginx/'):
        run('cat dead.letter')

def get_sample():
    with cd('/home/nginx/GN-Drive/www'):
        sudo('python build_svm.py', user='nginx')
        get('sample.dat')

def put_svm():
    with cd('/home/nginx/GN-Drive/www'):
        put('snap.svm', '')
        sudo('cp /home/ofshellohicy/snap.svm .', user='nginx')
    run('rm snap.svm')
