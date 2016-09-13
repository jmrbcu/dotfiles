import os
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


def install_ohmyzsh():
    cmd = 'sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"'

    try:
        output = check_output(shlex.split(cmd))
        print yellow(output)
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
    home = os.getenv('HOME')
    if not home:
        print red('Canot find home directory, exiting...')
        exit(1)

    home = os.path.abspath(home)
    install_ohmyzsh()
    link_files(home)
