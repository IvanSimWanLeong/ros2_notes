# ROS 2 Source CD function
ros2cd() {
    # -------------------------------------------------------------
    # TOP PARAMETERS
    # -------------------------------------------------------------
    local SEARCH_DEPTH=4  # Set your desired maximum search depth here
    # -------------------------------------------------------------

    if [ -z "$1" ]; then
        echo "Usage: ros2cd <package_name>"
        return 1
    fi

    local pkg_name="$1"
    local install_prefix
    local ws_src
    local pkg_path

    # 1. Get package prefix path using ros2 pkg prefix
    install_prefix=$(ros2 pkg prefix "$pkg_name" 2>/dev/null)

    # 2. Check if the package is an installed system package in /opt/
    if [[ "$install_prefix" == /opt/* ]]; then
        # System package: Direct to share directory in /opt
        pkg_path="$install_prefix/share/$pkg_name"
        if [ -d "$pkg_path" ]; then
            cd "$pkg_path" || return 1
            return 0
        fi
    elif [ -n "$install_prefix" ]; then
        # Workspace package: Navigate ../.. to reach workspace root, then append /src
        ws_src="$(dirname "$(dirname "$install_prefix")")/src"
    else
        # Fallback to current working dir or $ROS_WORKSPACE if prefix fails
        ws_src="${ROS_WORKSPACE:-$PWD}/src"
    fi

    # 3. Search for workspace package in src directory
    if [ -d "$ws_src" ]; then
        pkg_path=$(find -L "$ws_src" -maxdepth "$SEARCH_DEPTH" -name "package.xml" \
            -exec grep -lq "<name>$pkg_name</name>" {} \; \
            -exec dirname {} \; 2>/dev/null | head -n 1)
    fi

    # 4. Change directory if source path found
    if [ -n "$pkg_path" ] && [ -d "$pkg_path" ]; then
        cd "$pkg_path" || return 1
    else
        echo "Error: Package '$pkg_name' source directory not found in '$ws_src' (depth: $SEARCH_DEPTH)."
        return 1
    fi
}

_ros2cd_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local pkgs=""

    # 1. Primary: Use ros2 pkg list for completions
    if command -v ros2 &>/dev/null; then
        pkgs=$(ros2 pkg list 2>/dev/null)
    fi

    # 2. Fallback: Fast directory search if ros2 environment is not sourced
    if [ -z "$pkgs" ]; then
        local ws_src="${ROS_WORKSPACE:-$PWD}/src"
        if [ -d "$ws_src" ]; then
            pkgs=$(find -L "$ws_src" -maxdepth 4 -name "package.xml" -exec dirname {} + 2>/dev/null | xargs -n 1 basename)
        fi
    fi

    COMPREPLY=( $(compgen -W "$pkgs" -- "$cur") )
}

complete -F _ros2cd_complete ros2cd
