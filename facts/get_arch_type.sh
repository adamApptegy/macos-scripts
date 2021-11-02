arch_name="$(uname -m)"

if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
        ARCH_TYPE="arm"
    else
        echo "Running on native Intel"
        ARCH_TYPE="intel"
    fi
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    ARCH_TYPE="arm"
else
    echo "Unknown architecture: ${arch_name}"
    ARCH_TYPE="UNKNOWN"
fi

echo $ARCH_TYPE