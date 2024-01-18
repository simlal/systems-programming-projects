#!/bin/bash
# aliased to build-ift209 in .bashrc

function delete_build_files() {
    local dir=$1
    for f in $dir/*; do
        # output files
        if [[ $f == *.o ]] || [[ $f == *.out ]]; then
            rm $f
        fi
        # executables
        if [[ -x $f ]] && [[ -f $f ]]; then
            rm $f
        fi
    done

}

function move_to_build_dir() {
    local dir=$1
    for f in $dir/*; do
        # output files
        if [[ $f == *.o ]] || [[ $f == *.out ]]; then
            mv $f build/
        fi
        # executables
        if [[ -x $f ]] && [[ -f $f ]]; then
            mv $f build/
        fi
    done
}

function find_binary() {
    local bin_found=false
    for f in build/*; do
        if [[ -x $f ]] && [[ -f $f ]]; then
            echo $f
            bin_found=true
            break
        fi
    done
    if [[ $bin_found == false ]]; then
        echo "No binary found in $(basename $CURRENT_DIR) directory post-build!"
        exit 1
    fi
}

CURRENT_DIR=$(pwd)

# Remove .o and binaries if present in working and build directories
echo "Cleaning previous build files in working $(basename $CURRENT_DIR)/ directory if any..."
delete_build_files "$CURRENT_DIR"

echo "Cleaning previous build files in working build/ directory if any..."
if [[ -d "$CURRENT_DIR/build" ]]; then
    delete_build_files "$CURRENT_DIR/build"
fi
echo "Done cleaning!"

# Create build dir for temp files
if [[ ! -d "$CURRENT_DIR/build" ]]; then
    mkdir build
fi



# Compile and execute
echo "Trying to build from makefile..."
# Check if makefile exists
if [[ ! -f "$CURRENT_DIR/MakeFile" ]] && [[ ! -f "$CURRENT_DIR/makefile" ]] && [[ ! -f "$CURRENT_DIR/Makefile" ]]; then
    echo "No makefile found in $CURRENT_DIR directory!"
    exit 1
fi

# Compiling and moving to build
make
move_to_build_dir "$CURRENT_DIR"

bin_name=$(find_binary)    # exit 1 if no binary found
echo "Executing binary ./$bin_name..."
./$bin_name

echo "Done execution!"
exit 0