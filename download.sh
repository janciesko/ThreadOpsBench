var=$1

if [ x"$var" = x"argobots" ] || [ x"$var" = x"all" ];then
echo "Downloading Argobots."
git clone https://github.com/pmodels/argobots.git
elif [ x"$var" = x"qthreads" ] || [ x"$var" = x"all" ];then
echo "Downloading Qthreads."
git clone https://github.com/Qthreads/qthreads.git
elif [ x"$var" = x"hpx" ] || [ x"$var" = x"all" ];then
echo "Downloading HPX."
git clone https://github.com/STEllAR-GROUP/hpx.git
elif [ x"$var" = x"legion" ] || [ x"$var" = x"all" ];then
echo "Downloading Legion."
git clone https://github.com/StanfordLegion/legion.git
else
echo "No selection made. Exiting."
fi

