# flappybash

Can _you_ beat the Unix pipes?

![FLAPPY BASH](http://xion.io/images/flappybash.jpg)

## Features

* State-of-the-art terminal graphics
* Procedurally generated sound effects
* Adjustable difficulty to challenge beginners and pros alike
* Hours of engaging gameplay

## Requirements

* Pentium processor or higher
* Unix-like operating system with a modern terminal (xterm, UTF-8)
* bash 4.0+ or compatible shell

### Recommended

* Linux operating system supporting ALSA
* Sound Blaster 16 or higher
* Speakers

## Manual

Run it normally:

    ./flappybash.sh

Press `SPACE` for things to happen.

Press `q` to quit.

You can change the effective screen width by passing an argument:

    ./flappybash.sh 120

Lower values make the game more difficult. Anything below 80 is probably not for the faint of heart.

## Troubleshooting

#### I only see gibberish, and then the game ends.

Your bash is too old. This most likely means you're running OSX
and you'd want to use Homebrew to install an up to date one:

    brew install bash

Check that `bash --version` is at least 4.0 and run the script again.
