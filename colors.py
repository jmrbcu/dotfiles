# -*- coding: utf-8 -*-
"""
Functions for wrapping strings in ANSI color codes.

Each function within this module returns the input string ``text``, wrapped
with ANSI color codes for the appropriate color.

For example, to print some text as green on supporting terminals::

    from colors import green
    print green("This text is green!")

Because these functions simply return modified strings, you can nest them::

    from colors import red, green
    print red("This sentence is red, except for " + green("these words, which are green") + ".")

If ``bold`` is set to ``True``, the ANSI flag for bolding will be flipped on
for that particular invocation, which usually shows up as a bold or brighter
version of the original color on most terminals.
"""


def _wrap_with(code):
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


if __name__ == '__main__':
    COLORS = (
        ('gray', gray), ('red', red), ('green', green), ('yellow', yellow), ('blue', blue),
        ('magenta', magenta), ('cyan', cyan), ('white', white), ('light_gray', light_gray),
        ('light_red', light_red), ('light_green', light_green), ('light_yellow', light_yellow),
        ('light_blue', light_blue), ('light_magenta', light_magenta), ('light_cyan', light_cyan),
        ('light_white', light_white),
    )

    print 'COLORS:'
    for name, color in COLORS:
        print color('This is a sentence in {0}'.format(' '.join(name.split('_'))))

    print
    print 'BOLD COLORS:'
    for name, color in COLORS:
        print color('This is a sentence in {0}'.format(' '.join(name.split('_'))), True)

