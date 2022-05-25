#!/bin/bash

# When facing the following error:
# /Users/abarrows/.rbenv/gems/ruby-2.5.3@dilbert/gems/nokogiri-1.10.9/lib/nokogiri.rb:32:in
# `require': incompatible library version -
# /Users/abarrows/.rbenv/gems/ruby-2.5.3@dilbert/gems/nokogiri-1.10.9/lib/nokogiri/nokogiri.bundle
# (LoadError)

# SOLUTION: Solargraph requires an older version of nokogiri (1.10.09 or older)
gem uninstall nokogiri -v 1.10.10
gem uninstall nokogiri -v 1.10.09
