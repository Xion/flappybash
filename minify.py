#!/usr/bin/env python
"""
Script to minify that other script.
"""
from __future__ import print_function

import os
import re
import sys

import bs4
import requests


DEFAULT_INPUT_FILE = './flappybash.sh'
DEFAULT_OUTPUT_FILE = './release/flappybash.sh'

MINIFIER_URL = 'http://bash-minifier.appspot.com/'

LIMIT = 1234


def main(argv):
    args = argv[1:]
    filename = args[0] if args else DEFAULT_INPUT_FILE
    with open(filename) as f:
        source = f.read()

    response = requests.post(MINIFIER_URL, data={'user_source': source})
    response.raise_for_status()

    html = bs4.BeautifulSoup(response.text, 'html.parser')
    textarea = [ta for ta in html.find_all('textarea')
                if ta.get('name') != 'user_source'][0]
    minified = textarea.text

    # fix minifier bugs:
    # * semicolon before function declaration requires additional whitespace
    # * ampersand (for background jobs) gets an erroneous semicolon
    minified = re.sub(
        r';(\w+)\(\)', lambda m: '; %s()' % m.group(1), minified)
    minified = minified.replace('&;', '&')

    # copy the original shebang and check final size against the limit
    minified = (source.splitlines()[0] + '\n' + minified).encode('utf8')
    size = len(minified)
    if size < LIMIT:
        print("Phew, output is below the size limit (%s < %s)" % (
            size, LIMIT), file=sys.stderr)
    else:
        print("ZOMG we're hitting the size limit!!!one (%s >= %s)" % (
            size, LIMIT), file=sys.stderr)

    # write it to the file or standard output
    output = sys.stdout
    if output.isatty():
        output = open(DEFAULT_OUTPUT_FILE, 'w')
        os.chmod(DEFAULT_OUTPUT_FILE, 0755)
    with output as out:
        print(minified, end='', file=out)


if __name__ == '__main__':
    sys.exit(main(sys.argv) or 0)
