#!/bin/bash

set -e

brew install libtiff libjpeg openjpeg libimagequant webp little-cms2 freetype

PYTHONOPTIMIZE=0 pip install cffi
pip install --pre "coverage>=5.0b1"
pip install olefile
pip install -U pytest
pip install -U pytest-cov
pip install pyroma
pip install test-image-results
pip install numpy

# extra test images
pushd depends && ./install_extra_test_images.sh && popd
