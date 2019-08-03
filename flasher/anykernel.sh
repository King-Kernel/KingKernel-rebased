# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=marlin
device.name2=sailfish
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# If the kernel image and dtbs are separated in the zip
decomp_image=$home/Image
comp_image=$decomp_image.lz4
if [ -f $comp_image ]; then
  # Hexpatch the kernel if Magisk is installed ('skip_initramfs' -> 'want_initramfs')
  comp_rd=$split_img/ramdisk.cpio
  decomp_rd=$home/_ramdisk.cpio
  $bin/magiskboot decompress $comp_rd $decomp_rd || cp $comp_rd $decomp_rd

  if $bin/magiskboot cpio $decomp_rd "exists .backup"; then
    ui_print " "; ui_print "• Found Magisk! Patching Kernel"; 
    $bin/magiskboot decompress $comp_image $decomp_image;
    $bin/magiskboot hexpatch $decomp_image 736B69705F696E697472616D667300 77616E745F696E697472616D667300;
    $bin/magiskboot compress=lz4 $decomp_image $comp_image;
  fi;

  # Concatenate all DTBs to the kernel
  cat $comp_image $home/dtbs/*.dtb > $comp_image-dtb;
  rm -f $decomp_image $comp_image
fi;

write_boot;
## end install

