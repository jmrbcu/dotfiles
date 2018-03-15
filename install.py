#!/usr/bin/env python
import os
import platform
import shutil
import shlex
import subprocess


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


def init_child_process():
    os.setpgrp()
    os.umask(022)


def is_program_installed(name):
    try:
        check_output('which {0}'.format(name), shell=True, stderr=subprocess.STDOUT)
        return True
    except CalledProcessError:
        return False


def install_homebrew():
    print green('Installing: {0}'.format(red('Homebrew', True)), True)

    home = os.getenv('HOME')
    if is_program_installed('brew'):
        return

    try:
        cmd = '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), green(e.output, True))
    finally:
        print

def install_program(name):
    system = platform.system().lower()

    if 'darwin' in system:
        cmd = 'brew install {0}'.format(name)
    elif 'linux' in system:
        dist = platform.dist()[0].lower()
        if dist in ('ubuntu', 'debian'):
            cmd = 'sudo apt-get install -y {0}'.format(name)
        elif dist == 'centos':
            cmd = 'sudo yum install -y {0}'.format(name)
        else:
            raise RuntimeError(red('Cannot determine the system type, cannot install zsh.'))
    else:
        raise RuntimeError(red('Cannot determine the system type, cannot install zsh.'))

    try:
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT)
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), green(e.output, True))


def install_ohmyzsh():
    print green('Installing: {0}'.format(red('oh-my-zsh', True)), True)

    home = os.getenv('HOME')
    current = os.path.abspath(os.path.dirname(__file__))
    if not is_program_installed('zsh'):
        install_program('zsh')

    zsh_dir = os.path.join(home, '.oh-my-zsh')
    backup = os.path.join(home, '.oh-my-zsh-save')
    if os.path.exists(zsh_dir):
        print green('\tBacking up folder: {0} --> {1}'.format(cyan(zsh_dir), cyan(backup)), True)
        if os.path.exists(backup):
            shutil.rmtree(backup)
        shutil.move(zsh_dir, backup)

    try:
        # clone zsh repo
        cmd = 'git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git {0}'.format(zsh_dir)
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)

        target = os.path.join(current, '.zshrc')
        zshrc = os.path.join(home, '.zshrc')
        print green('\tSymlinking file: {0} --> {1}'.format(cyan(zshrc), cyan(target)), True)
        check_output(shlex.split('ln -sf {0} {1}'.format(target, zshrc)))

        target = os.path.join(current, 'custom.zsh-theme')
        theme = os.path.join(home, '.oh-my-zsh/custom/themes/custom.zsh-theme')
        print green('\tSymlinking file: {0} --> {1}'.format(cyan(theme), cyan(target)), True)
        check_output(shlex.split('mkdir -p {0}'.format(os.path.dirname(theme))))
        check_output(shlex.split('ln -sf {0} {1}'.format(target, theme)))

        # zsh syntax highlighting
        path = os.path.join(zsh_dir, "custom/plugins/zsh-syntax-highlighting")
        cmd = "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git {0}".format(path)
        print green('Installing zsh syntax highlighting')
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)

        # zsh autosuggestions
        path = os.path.join(zsh_dir, "custom/plugins/zsh-autosuggestions")
        cmd = "git clone https://github.com/zsh-users/zsh-autosuggestions.git {0}".format(path)
        print green('Installing zsh autosuggestions')
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)

        # change the shell
        if 'zsh' not in os.environ['SHELL']:
            os.system('chsh -s $(grep /zsh$ /etc/shells | tail -1)')
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), green(e.output, True))
    finally:
        print


def install_vim():
    print green('Installing: {0}'.format(red('vim', True)), True)

    home = os.getenv('HOME')
    if not is_program_installed('vim'):
        install_program('vim')

    vim_dir = os.path.join(home, '.vim')
    backup = os.path.join(home, '.vim-save')
    if os.path.exists(vim_dir):
        print green('\tBacking up folder: {0} --> {1}'.format(cyan(vim_dir), cyan(backup)), True)
        if os.path.exists(backup):
            shutil.rmtree(backup)
        shutil.move(vim_dir, backup)

    vimrc = os.path.join(home, '.vimrc')
    backup = os.path.join(home, '.vimrc-save')
    if os.path.exists(vimrc):
        print green('\tBacking up file: {0} --> {1}'.format(cyan(vimrc), cyan(backup)), True)
        if os.path.exists(backup):
            os.remove(backup)
        shutil.move(vimrc, backup)

    try:
        # clone vimconf repo
        cmd = 'git clone https://github.com/timss/vimconf.git {0}'.format(vim_dir)
        # print green(check_output(shlex.split(cmd), stderr=subprocess.STDOUT))
        check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)

        target = os.path.join(vim_dir, '.vimrc')
        vimrc = os.path.join(home, '.vimrc')
        print green('\tSynlinking file: {0} --> {1}'.format(cyan(vimrc), cyan(target)), True)
        check_output(shlex.split('ln -sf {0} {1}'.format(target, vimrc)))

    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), green(e.output, True))
    finally:
        print

def install_extras():
    system = platform.system().lower()
    if 'darwin' in system:
        pymodules = "virtualenv virtualenvwrapper"
        console = (
            'coreutils cabextract p7zip unrar xz rpm mc htop archey brew-cask-completion bash-completion '
            'zsh-completions openssl openssl@1.1 python python@2 ipython ipython@5 git subversion httpie '
            'mplayer lame ffmpeg ctags sox sqlite ssh-copy-id watch wget speedtest-cli youtube-dl '
        )
    elif 'linux' in system:
        pymodules = ''
        dist = platform.dist()[0].lower()
        if dist in ('ubuntu', 'debian'):
            pymodules = "virtualenv virtualenvwrapper"
            console = (
                'cabextract p7zip-full unrar xz-utils rpm mc htop bash-completion git httpie '
                'exuberant-ctags python-pip ipython'
            )
        elif dist == 'centos':
            pymodules = "httpie virtualenv virtualenvwrapper"
            console = 'cabextract p7zip unrar xz mc htop bash-completion git ctags python-ipython-console'
        else:
            raise RuntimeError(red('Cannot determine the system type, cannot install zsh.'))
    else:
        raise RuntimeError(red('Cannot determine the system type, cannot install zsh.'))

    try:
        # install extra console apps
        print green('\tInstalling console apps: {0}'.format(cyan(console)), True)
        install_program(console)

        # install extra python modules
        if pymodules:
            print green('\tInstalling python modules: {0}'.format(cyan(pymodules)), True)
            cmd = 'pip install --upgrade ' + pymodules
            check_output(shlex.split(cmd), stderr=subprocess.STDOUT, preexec_fn=init_child_process)
    except CalledProcessError as e:
        print '{0}\n{1}'.format(red(e, True), green(e.output, True))
    finally:
        print


def link_files():
    filenames = ('.bashrc', '.dircolors', '.inputrc', '.profile', '.Xdefaults')
    print green('Symlinking files: {0}'.format(red(filenames, True)), True)

    home = os.getenv('HOME')
    current = os.path.abspath(os.path.dirname(__file__))

    for filename in filenames:
        target = os.path.join(home, filename)
        if os.path.exists(target):
            print green('\tBacking up file: {0} --> {1}'.format(cyan(target), cyan(target + '-save')), True)
            shutil.move(target, target + '-save')

        print green('\tSymlinking file: {0} --> {1}'.format(cyan(os.path.join(current, filename)), cyan(target)), True)
        os.symlink(os.path.join(current, filename), target)
        print


if __name__ == '__main__':
    install_vim()
    install_ohmyzsh()
    install_extras()
    link_files()
    print green('Finished.', True)
