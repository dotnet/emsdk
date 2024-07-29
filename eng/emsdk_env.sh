CURRENT_SCRIPT=
DIR="."

# use shell specific method to get the path
# to the current file being source'd.
#
# To add a shell, add another conditional below,
# then add tests to scripts/test_source_env.sh

if [ -n "${BASH_SOURCE-}" ]; then
  CURRENT_SCRIPT="$BASH_SOURCE"
elif [ -n "${ZSH_VERSION-}" ]; then
  CURRENT_SCRIPT="${(%):-%x}"
elif [ -n "${KSH_VERSION-}" ]; then
  CURRENT_SCRIPT=${.sh.file}
fi

if [ -n "${CURRENT_SCRIPT-}" ]; then
  DIR=$(dirname "$CURRENT_SCRIPT")
  if [ -h "$CURRENT_SCRIPT" ]; then
    # Now work out actual DIR since this is part of a symlink.
    # Since we can't be sure that readlink or realpath
    # are available, use tools more likely to be installed.
    # (This will still fail if sed is not available.)
    SYMDIR=$(dirname "$(ls -l "$CURRENT_SCRIPT" | sed -n "s/.*-> //p")")
    if [ -z "$SYMDIR" ]; then
      SYMDIR="."
    fi
    FULLDIR="$DIR/$SYMDIR"
    DIR=$(cd "$FULLDIR" > /dev/null 2>&1; /bin/pwd)
    unset SYMDIR
    unset FULLDIR
  fi
fi
unset CURRENT_SCRIPT

if [ ! -f "$DIR/emscripten/emcmake.py" ]; then
  echo "Error: unable to determine 'emsdk' directory. Perhaps you are using a shell or" 1>&2
  echo "       environment that this script does not support." 1>&2
  echo 1>&2
  echo "A possible solution is to source this script while in the 'emsdk' directory." 1>&2
  echo 1>&2
  unset DIR
  return
fi
export EMSDK_PATH=${DIR}/
unset DIR

export DOTNET_EMSCRIPTEN_LLVM_ROOT=${EMSDK_PATH}bin/
export DOTNET_EMSCRIPTEN_NODE_JS=${EMSDK_PATH}node/bin/node
export DOTNET_EMSCRIPTEN_BINARYEN_ROOT=${EMSDK_PATH}
#!/bin/bash
echo "*** .NET EMSDK path setup ***"

# emscripten (emconfigure, em++, etc)
if [ -z "${EMSDK_PATH}" ]; then
echo "/$EMSDK_PATH is empty"
exit 1
fi
TOADD_PATH_EMSCRIPTEN="$(realpath ${EMSDK_PATH}/emscripten)"
echo "PATH += ${TOADD_PATH_EMSCRIPTEN}"
export PATH=${TOADD_PATH_EMSCRIPTEN}:$PATH

# llvm (clang, etc)
if [ -z "${DOTNET_EMSCRIPTEN_LLVM_ROOT}" ]; then
echo "/$DOTNET_EMSCRIPTEN_LLVM_ROOT is empty"
exit 1
fi
TOADD_PATH_LLVM="$(realpath ${DOTNET_EMSCRIPTEN_LLVM_ROOT})"
if [ "${TOADD_PATH_EMSCRIPTEN}" != "${TOADD_PATH_LLVM}" ]; then
echo "PATH += ${TOADD_PATH_LLVM}"
export PATH=${TOADD_PATH_LLVM}:$PATH
fi

# nodejs (node)
if [ -z "${DOTNET_EMSCRIPTEN_NODE_JS}" ]; then
echo "/$DOTNET_EMSCRIPTEN_NODE_JS is empty"
exit 1
fi
TOADD_PATH_NODEJS="$(dirname ${DOTNET_EMSCRIPTEN_NODE_JS})"
if [ "${TOADD_PATH_EMSCRIPTEN}" != "${TOADD_PATH_NODEJS}" ] && [ "${TOADD_PATH_LLVM}" != "${TOADD_PATH_NODEJS}" ]; then
echo "PATH += ${TOADD_PATH_NODEJS}"
export PATH=${TOADD_PATH_NODEJS}:$PATH
fi

# binaryen (wasm-opt, etc)
if [ -z "${DOTNET_EMSCRIPTEN_BINARYEN_ROOT}" ]; then
echo "/$DOTNET_EMSCRIPTEN_BINARYEN_ROOT is empty"
exit 1
fi
TOADD_PATH_BINARYEN="$(realpath ${DOTNET_EMSCRIPTEN_BINARYEN_ROOT}/bin)"
if [ "${TOADD_PATH_EMSCRIPTEN}" != "${TOADD_PATH_BINARYEN}" ] && [ "${TOADD_PATH_LLVM}" != "${TOADD_PATH_BINARYEN}" ] && [ "${TOADD_PATH_NODEJS}" != "${TOADD_PATH_BINARYEN}" ]; then
echo "PATH += ${TOADD_PATH_BINARYEN}"
export PATH=${TOADD_PATH_BINARYEN}:$PATH
fi
