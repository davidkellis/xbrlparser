#!/bin/sh

rake clobber_package
rake gem
gem install pkg/*.gem
