var=$1

if [ x"$var" = x"argobots" ] || [ x"$var" = x"all" ];then
    echo "Building Argobots benchmark."
    make argobots
fi
if [ x"$var" = x"pthreads" ] || [ x"$var" = x"all" ];then
    echo "Building Pthreads benchmark."
    make pthreads
fi
if [ x"$var" = x"qthreads" ] || [ x"$var" = x"all" ];then
    echo "Building Qthreads benchmark."
    make qthreads
fi
if [ x"$var" = x"hpx" ] || [ x"$var" = x"all" ];then
    echo "Building HPX benchmark."
    #make hpx
fi
if [ x"$var" = x"legion" ] || [ x"$var" = x"all" ];then
    echo "Building Legion benchmark."
    #make legion
fi
if [ x"$var" = x"openmp" ] || [ x"$var" = x"all" ];then
    echo "Building Legion benchmark."
    make openmp
fi
if [ x"$var" = x"async" ] || [ x"$var" = x"all" ];then
    echo "Building std::async benchmark."
    make stdasync
fi

if [ x"$var" = x ];then
echo "No selection made. Exiting."
fi

