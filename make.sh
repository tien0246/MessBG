rm -rf packages
make clean
make package
cp .theos/obj/MessengerBackground.dylib packages
make package THEOS_PACKAGE_SCHEME=rootless