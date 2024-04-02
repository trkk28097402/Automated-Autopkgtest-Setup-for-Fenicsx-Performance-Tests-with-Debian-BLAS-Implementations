#!/bin/bash
# Back to $HOME, Setting Environment Variables
cd $HOME
ARCH=x86_64-linux-gnu
LIB_HOME=/usr/lib/$ARCH
FENICS_VERSION=fenicsx-performance-tests-0.5.0~git20220731.821823b
NPROC=2

# Update package list
sudo apt update

# Install autopkgtest dpkg-dev
sudo apt install -y autopkgtest dpkg-dev

# Install dependency for fenicsx-performance-tests
dependencies=$(apt-cache depends fenicsx-performance-tests | grep "Depends:" | cut -d ":" -f 2-)

for dependency in $dependencies
do
    echo "Installed $dependency"
    sudo apt install -y $dependency
done

# Install source for fenicsx-performance-tests
apt source fenicsx-performance-tests

# Install BLAS Implementations
blas_packages="libblas* libatlas* libopenblas* libgslcblas* libblis*"

for blas_package in $blas_packages
do
    echo "Installed $blas_package"
    sudo apt install -y $blas_package
done

# Remove redundant package
sudo apt autoremove -y
sudo apt remove -y libblasr*

# Put GSL libgslcblas into alternatives of libblas.so-x86_64-linux-gnu, which didn't in it by default
sudo update-alternatives --install $LIB_HOME/libblas.so-$ARCH libblas.so-$ARCH $LIB_HOME/libgslcblas.so.0 10

# Loop over all the BLAS Implementation and run FEniCS with autopkgtest
alternatives=$(update-alternatives --display libblas.so-$ARCH | grep '^/' | awk '{print $1}')

for alt in $alternatives
do
    echo "Switching to $alt"
    sudo update-alternatives --set libblas.so-$ARCH $alt
    
    alt=${alt#$LIB_HOME/}
    alt=${alt%/libblas.so}
    echo "Benchmarking with $alt"
    sudo autopkgtest \
        --output-dir $HOME/fenics-benchmarking-rs/$alt \
        --build-parallel $NPROC \
        --env OMPI_ALLOW_RUN_AS_ROOT=1 \
        --env OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1 \
        $FENICS_VERSION \
        -- null
done
