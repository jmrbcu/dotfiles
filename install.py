import os
import platform
import shutil
import shlex
import subprocess
import fnmatch
from colors import *


class CalledProcessError(Exception):
    """
    We don't have this exception with the output field in python 2.6 so I back ported it
    """
    def __init__(self, returncode, cmd, output=None):
        self.returncode = returncode
        self.cmd = cmd
        self.output = output

    def __str__(self):
        return "Command '%s' returned non-zero exit status %d" % (self.cmd, self.returncode)


def check_output(*popenargs, **kwargs):
    """
    We don't have this function in python 2.6 so I back ported it
    """
    if 'stdout' in kwargs:
        raise ValueError('stdout argument not allowed, it will be overridden.')
    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        raise CalledProcessError(retcode, cmd, output=output)
    return output


def is_zsh_installed():
    with open('/etc/shells') as f:
        return 'zsh' in f.read()


def install_zsh():
    system = platform.system().lower()
    if 'darwin' in system:
        cmd = 'brew install zsh'
    elif 'linux' in system:
        dist = platform.dist()[0].lower()
        if dist in ('ubuntu', 'debian'):
            cmd = 'sudo apt-get install -y zsh'
        elif dist == 'centos':
            cmd = 'sudo yum install -y zsh'
        else:
            raise RuntimeError('Cannot determine the system type, cannoy install zsh.')
    else:
        raise RuntimeError('Cannot determine the system type, cannot install zsh.')

    try:
        print yellow(check_output(shlex.split(cmd)))
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), yellow(e.output, True))


def install_ohmyzsh():
    def init_child_process():
        os.setpgrp()
        os.umask(022)

    home = os.getenv('HOME')
    if not home:
        print red('Cannot find home directory, exiting...', True)
        return

    if not is_zsh_installed():
        try:
            install_zsh()
        except RuntimeError as e:
            print red(e.message, True)
            return

    zsh_dir = os.path.join(home, '.oh-my-zsh')
    if os.path.exists(zsh_dir):
        print red('You already have Oh My Zsh installed.', True)
        print red('You will need to remove {0} if you want to re-install.'.format(zsh_dir), True)
        return

    try:
        cmd = 'git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git {0}'.format(zsh_dir)
        print yellow(check_output(shlex.split(cmd), preexec_fn=init_child_process), True)
        os.system('chsh -s $(grep /zsh$ /etc/shells | tail -1)')
        return True
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), yellow(e.output, True))
        return False


def link_files(home):
    current = os.path.abspath(os.path.dirname(__file__))
    for filename in os.listdir(current):
        if not fnmatch.fnmatch(filename, '.*') or filename in ('.git', '.gitignore', '.idea'):
            continue

        full_filename = os.path.join(home, filename)
        if os.path.exists(full_filename):
            msg = 'Configuration file exists: {0}, backing it up to: {1}'
            print yellow(msg.format(blue(full_filename, True), blue(full_filename + '.save', True)), True)
            shutil.move(full_filename, full_filename + '.save')

        print yellow('Linking file: {0}'.format(blue(os.path.join(current, filename), True)), True)
        os.symlink(os.path.join(current, filename), full_filename)


if __name__ == '__main__':
    home_dir = os.getenv('HOME')
    if not home_dir:
        print red('Cannot find home directory, exiting...')
        exit(1)

    install_ohmyzsh()
    link_files(home_dir)
