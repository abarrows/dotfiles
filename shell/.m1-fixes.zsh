#!/usr/bin/env bash

# First check if machine is an m1 mac or not
if [[ $(uname -m) == "arm64" ]]; then
  echo "M1 Mac Detected - Applying patch fixes for MySQL."

  # Mysql OpenSSL and M1 fix
  export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
  export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
  export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
  export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
else
  echo "Intel Mac Detected - No patch fixes needed."
fi
