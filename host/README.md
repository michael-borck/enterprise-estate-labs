# Host VM

The Docker estate is not an operating system installation. ISYS2008 also requires a real
Ubuntu Server install, so that students select, install and configure an OS rather than
only run containers.

This folder will hold the reproducible host bootstrap:

- A Multipass or UTM profile for a local Ubuntu Server VM.
- A cloud-init file for the first boot.
- A short guide for students who use VirtualBox instead.
- A smoke test that proves the VM is reachable over SSH and has Docker installed.

Until that exists, the unit repo owns the host installation instructions and this repo
assumes a Linux host with Docker or Podman.
