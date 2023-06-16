var=$1

if [ x"$var" = x"argobots" ] || [ x"$var" = x"all" ];then
    echo "Building Argobots."
    cd argobots
    sh autogen.sh
    ./configure --enable-fast=O3 --enable-debug=none --enable-tls-model=initial-exec --enable-checks=no --enable-feature=no --prefix=$(pwd)/install
    make -j install
    cd ..
fi
if [ x"$var" = x"qthreads" ] || [ x"$var" = x"all" ];then
    echo "Building Qthreads."
    cd argobots
    sh autogen.sh
    ./configure --enable-fast=O3 --enable-debug=none --enable-tls-model=initial-exec --enable-checks=no --enable-feature=no --prefix=$(pwd)/install
    make -j install
    cd ..
fi
if [ x"$var" = x"hpx" ] || [ x"$var" = x"all" ];then
    echo "Building HPX."
    cd hpx
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release -DHPX_WITH_FETCH_ASIO=ON -DHPX_WITH_MALLOC=On
    make -j 
    cd ../../
fi
if [ x"$var" = x"legion" ] || [ x"$var" = x"all" ];then
    echo "Building Legion."
    cd legion
    mkdir build
    cd build
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j 
    cd ../../
fi

if [ x"$var" = x ];then
echo "No selection made. Exiting."
fi

