cd argobots
sh autogen.sh
./configure --enable-fast=O3 --enable-debug=none --enable-tls-model=initial-exec --enable-checks=no --enable-feature=no --prefix=$(pwd)/install
make -j install
cd ..

cd qthreads
./autogen.sh
./configure --prefix=$(pwd)/install CFLAGS="-O3" CXXFLAGS="-O3"
make -j install
cd ..

gcc -O3 benchmark.c -DUSE_PTHREADS -std=gnu99 -lpthread -o run_pthreads
gcc -O3 benchmark.c -DUSE_QTHREADS -std=gnu99 -lqthread -L $(pwd)/qthreads/install/lib -I $(pwd)/qthreads/install/include -Wl,-rpath=$(pwd)/qthreads/install/lib -o run_qthreads
gcc -O3 benchmark.c -DUSE_ARGOBOTS -std=gnu99 -labt -L $(pwd)/argobots/install/lib -I $(pwd)/argobots/install/include -Wl,-rpath=$(pwd)/argobots/install/lib -o run_argobots
