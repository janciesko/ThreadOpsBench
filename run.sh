current_dir=$(pwd)

export LD_LIBRARY_PATH=$current_dir/qthreads/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$current_dir/argobots/install/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$current_dir/hpx/install/lib64:$LD_LIBRARY_PATH

echo $current_dir/qthreads/install/lib

export QT_NUM_WORKERS_PER_SHEPHERD=1
export QT_NUM_SHEPHERDS=1

num_repeats=4096
num_threads=16
num_yields=4096
num_warmups=128
for reps in $(seq 1 10); do
  for thread_type in openmp;do #pthreads stdasync openmp qthreads argobots; do
    ./run_$thread_type -r $num_repeats -w $num_warmups -y $num_yields -t $num_threads -c
  done
done
