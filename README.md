# osbuild initrd

osbuild/initrd is a single static binary intended to be used in an
initrd, in combination with qemu and virtiofsd to boot virtual
machines without using a disk image. The primary user of this is the
--in-vm suport in osbuild that uses an existing build pipeline as the
rootfs to boot a vm in.

# Creating an initrd

An initrd is a cpio archive, and the main osbuild/initrd binary should
be in it as "/init". Additionally (if needed for mounting the virtiofs
filesystem), extra modules can be stored in the /usr/lib/modules
directory. No other files are needed in the cpio archive.

# Behaviour

During boot, the initrd does this:

 * Mount various filesystems (sysfs, devtmpfs, proc, tmpfs)
 * Create files in `/dev` that can are needed
 * Load, in alphabetical order, any kernel modules in
   `/usr/lib/modules`.
 * Give `rootfs=$TAG` option on the commandline, mount virtiofs `$TAG`
   at `/sysroot`
 * Look for any `mount=$TAG` or `mount-ro=$TAG` commandline options
   and mount corresponding virtiofs at `/run/mount/$TAG`
 * Switchroot into `/sysroot`, moving `/run`, `/dev, ``/proc`,
   `/sys`, and `/tmp` to the new root.
 * Execute, as pid1, `/bin/sh`, or whatever is in the `init=` kernel
   command line.

Often you want to run as init something that is not part of the
rootfs. For example, osbuild wants to run the `vm.py` python script as
the main binary to control the vm. This can be achieved by mounting
this script as a separate virtiofs mount and pointing at that. For
example, osbuild uses `mount=mnt0 init=/run/mnt/mnt0/osbuild/vm.py`
and mounts the osbuild python dir as `mnt0`.

If any modules are needed it is best to sort them in dependency order
by name in the initrd, as no module dependency resolution is done at
runtime.

# Commandline

These options are supported:

 * `rootfs=$TAG` (required) - mount read-only the virtiofs with the given tag as the new rootfs
 * `debug` - if this is set, debug spew is printed
 * `mount=$TAG` mount the virtiofs filesystem with the given tag under `/run/mnt/$TAG`
 * `mount-ro=$TAG` mount read-only the virtiofs filesystem with the given tag under `/run/mnt/$TAG`

# Build and install

There is a Makefile with these targets:

 * all: vendor, build
 * vendor: Update the vendored files (not needed if building from release tarball)
 * build: Build main binary
 * install: Install main binary in /usr/lib/osbuild/initrd/initrd

# Helper scripts

For development and testing, some scripts are shipped in the git repo:

 * `mkvirtinitrd` - creates initrd cpio image given path to main
   binary and directory of modules
 * `chrootvm` - uses qemu, virtiofs and mkvirtinitrd to create and
   boot a VM given a rootfs directory, using the kernel and modules
   from that rootfs.
