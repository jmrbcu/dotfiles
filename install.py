#!/usr/bin/env python
import os
import platform
import shutil
import shlex
import subprocess
import fnmatch


def _wrap_with(code):
    """
    Decorator for wrapping strings in ANSI color codes.

    Ej:
        print green("This text is green!")
        print red("This text is green!", bold=True)
        print yellow("This text is green!", True)
    """
    def inner(text, bold=False):
        c = code
        if bold:
            c = "1;%s" % c
        return "\033[%sm%s\033[0m" % (c, text)
    return inner


gray = _wrap_with('30')
red = _wrap_with('31')
green = _wrap_with('32')
yellow = _wrap_with('33')
blue = _wrap_with('34')
magenta = _wrap_with('35')
cyan = _wrap_with('36')
white = _wrap_with('37')

light_gray = _wrap_with('30')
light_red = _wrap_with('31')
light_green = _wrap_with('32')
light_yellow = _wrap_with('33')
light_blue = _wrap_with('34')
light_magenta = _wrap_with('35')
light_cyan = _wrap_with('36')
light_white = _wrap_with('37')


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
            raise RuntimeError(red('Cannot determine the system type, cannoy install zsh.'))
    else:
        raise RuntimeError(red('Cannot determine the system type, cannot install zsh.'))

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
        raise RuntimeError(red('Cannot find home directory, exiting.'))

    if not is_zsh_installed():
        install_zsh()

    zsh_dir = os.path.join(home, '.oh-my-zsh')
    if os.path.exists(zsh_dir):
        raise RuntimeError(red('You already have Oh My Zsh installed. Remove {0} before install.'.format(zsh_dir)))

    try:
        # clone zsh repo
        cmd = 'git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git {0}'.format(zsh_dir)
        print yellow(check_output(shlex.split(cmd), preexec_fn=init_child_process), True)

        # link the config files
        link_files(home)

        # change the shell
        if 'zsh' not in os.environ['SHELL']:
            os.system('chsh -s $(grep /zsh$ /etc/shells | tail -1)')
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), yellow(e.output, True))


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

        print yellow(
            'Linking file: {0} --> {1}'.format(blue(os.path.join(current, filename), True), blue(full_filename)), True
        )
        os.symlink(os.path.join(current, filename), full_filename)


if __name__ == '__main__':
    install_ohmyzsh()
