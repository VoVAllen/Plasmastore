ARROW_CUDA=${ARROW_CUDA:-OFF}
cd /io
mkdir -p build
cd build

if [ "${ARROW_CUDA}" == "ON" ]; then
    cp /usr/local/lib/libarrow_cuda.so.300.0.0 /io/build/libarrow_cuda.so.300
    patchelf --set-rpath "./" /io/build/libarrow_cuda.so.300
    # Link against CUDA stubs when compiling
    export CMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:${LIBRARY_PATH}:${CMAKE_LIBRARY_PATH}
    export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:${LIBRARY_PATH}:${LD_LIBRARY_PATH}:/usr/local/lib
    cp /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
fi

cmake -DARROW_CUDA=${ARROW_CUDA} ..
make -j
echo "ARROW_CUDA=${ARROW_CUDA}"
cp /usr/local/lib/libarrow.so.300.0.0 /io/build/libarrow.so.300
