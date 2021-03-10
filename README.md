[![build](https://travis-ci.org/ajay0/sandbox.svg?branch=master)](https://travis-ci.org/ajay0/sandbox)

A sandbox written primarily using C, that is capable of executing untrusted applications
with various restrictions/limits thus reducing/preventing any damage to the user's system.

## Features
* Allows setting limits on **Memory** used, **CPU Time** taken and **number of pids** allotted to
  the untrusted executable.
* Supports **blocking specific system calls** made by the untrusted executable.
  The default behavior is to use a whitelist file that dictates which system
  calls to allow. This can be changed to a blacklisting approach quite easily.
* **File system access restriction** using chroot. This allows a specified directory
  to behave as the root for the untrusted executable.
* The untrusted executable can be run with a specified uid and gid.
* **Multi-process sandboxing**: Supports all the above even if the untrusted executable
  creates descendant processes.

## Requirements
* An OS running the Linux kernel v4.8-rc1 or greater. With older versions some features may not
  work. For instance with >= v4.4 and < v4.8-rc1, limiting number of pids allotted will work, (i.e if the
  sandboxed executable makes calls to fork()/clone() after hitting its limit, these calls will fail),
  but the executable won't be terminated for this reason by the sandbox.

* `gcc`, `make` for building the project.
* [cgroups](http://man7.org/linux/man-pages/man7/cgroups.7.html) v1 mounted with
  `memory`, `cpuacct` and `pids` controllers. It is possible that these are already
  mounted at `/sys/fs/cgroup/memory`,  `/sys/fs/cgroup/cpuacct` and `sys/fs/cgroup/pids`
  respectively. You could create a sub directory in each of these directories to use with the sandbox.
* [libseccomp](https://github.com/seccomp/libseccomp) for system call blocking.
  This might be installable using your package manager.

## Using the sandbox
* Get a local copy of this repository, change your working directory to the
  root of this project and build:
  ```
    $ make
  ```
* The path to the built executable is `bin/sandbox` (relative to the root of the project).
* Using the sandbox, requires root privileges:
  ```
    $ sudo bin/sandbox
  ```
  folowed by 13 mandatory positional arguments -

  1. Memory limit: Specified in bytes such as `12` for 12 bytes. Accepts
     human friendly notations such as `1M` for 1 Mega Byte.
     This value is directly written to `memory.limit_in_bytes` in the relevant cgroup.
     Thus whatever notations are accepted by the controller are valid here.
  2. CPU time limit: Specified in nanoseconds such as `1000000000` for 1 second.
  3. Max number of pids to allot: `2` for the limit to be two.
  4. Path to a `memory` cgroup to use. A possible location for this is the directory
     `/sys/fs/cgroup/memory/sandbox` assuming `memory` controller is already mounted at
     `/sys/fs/cgroup/memory`. If not absolute, it is relative to the working directory.
  5. Path to a `cpuacct` cgroup to use. A possible location for this is the directory
     `/sys/fs/cgroup/cpuacct/sandbox` assuming `cpuacct` controller is already mounted at
     `/sys/fs/cgroup/cpuacct`. If not absolute, it is relative to the working directory.
  6. Path to a `pids` cgroup to use. A possible location for this is the directory
     `/sys/fs/cgroup/pids/sandbox` assuming `pids` controller is already mounted at
     `/sys/fs/cgroup/pids`. If not absolute, it is relative to the working directory.
  7. Path to the jail directory that is to be used as the root directory for the
     untrusted executable. If not absolute, it is relative to the working directory.
  8. Path to the executable that is to be sandboxed. This executable must be
     present in the jail and the path must specified be relative to the jail.
  9. Path to input file that will be used as stdin for the first process
     of the sandboxed executable. If not absolute, it is relative to the working directory.
  10. Path to output file to which the stdout of the first process of the
     sandboxed executable will be directed. If not absolute, it is relative to the working directory.
  11. Path to the whitelist file containing names of system calls to allow,
      each on a separate line with a newline after the last system call
      specified. If not absolute, it is relative to the working directory.
  12. The uid to run the executable as. Expected to not have root privileges.
  13. The gid to run the executable as. Expected to not have root privileges.

* Running tests requires root privileges and assumes cgroups v1 controllers `memory`, `cpuacct` and `pids` are
  mounted at `/sys/fs/cgroup/memory`,  `/sys/fs/cgroup/cpuacct` and `sys/fs/cgroup/pids` respectively.
  To run tests, first build the sandbox and then use:
  ```
    $ sudo make test
  ```

* To delete all files created during the build, including the built executable:
  ```
    $ make clean
  ```