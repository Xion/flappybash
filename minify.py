#!/usr/bin/env python
"""
Script to minify that other script.
"""
from __future__ import print_function

import re
import sys

import bs4
import requests


DEFAULT_FILENAME = './flappybash.sh'
MINIFIER_URL = 'http://bash-minifier.appspot.com/'


def main(argv):
    args = argv[1:]
    filename = args[0] if args else DEFAULT_FILENAME
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
    #   at the end of a function
    minified = re .sub(
        r';(\w+)\(\)', lambda m: '; %s()' % m.group(1), minified)
    minified = minified.replace('&;}', '&}')

    print(source.splitlines()[0])  # copy the original shebang
    print(minified.encode('utf8'))


if __name__ == '__main__':
    sys.exit(main(sys.argv) or 0)
