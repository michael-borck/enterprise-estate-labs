# Host VM

The container estate is not an operating system installation. ISYS2008 also requires a
real Ubuntu Server install, so that students select, install and configure an OS rather
than only run containers.

This folder will hold the reproducible host bootstrap:

- A Multipass profile for a local Ubuntu Server VM (the default).
- A UTM profile for students who prefer a GUI, including Apple Silicon.
- A cloud-init file for the first boot.
- A smoke test that proves the VM is reachable over SSH and has the container runtime
  installed.

Until that exists, the unit repo owns the host installation instructions and this repo
assumes a Linux host with Docker or Podman.
