# ktails

*(re)boot into Tails without needing a USB stick!*

This project provides a script that will fetch the latest Tails release,
manipulate it, and then use Linux's `kexec` in order to boot directly into it.

This probably doesn't work if you have Secure Boot enabled. But there's probably also
a way to sign the kernel/initrd(?) to make it work.

This script expects to find the following on `${PATH}`: `[ jq aria2c 7z ]`.

If you like, you can copy/paste this to boot without leaving a trace on your system:

`curl --proto '=https' --tlsv1.2 -sSf "https://raw.githubusercontent.com/colemickens/ktails/master/kexec-tails.sh" | sh`


```bash
[cole@xeep:~/code/ktails]$ ./kexec-tails.sh 

10/28 19:14:14 [NOTICE] Downloading 1 item(s)

10/28 19:14:14 [NOTICE] Download complete: /tmp/ktails.upawW2/tails-amd64-4.0.img.torrent

10/28 19:14:14 [NOTICE] IPv4 DHT: listening on UDP port 6956

10/28 19:14:14 [NOTICE] IPv4 BitTorrent: listening on TCP port 6932

10/28 19:14:14 [NOTICE] IPv6 BitTorrent: listening on TCP port 6932
[#cce3fe 1.0GiB/1.0GiB(99%) CN:44 SD:33 DL:34MiB]
10/28 19:15:09 [NOTICE] Seeding is over.
[#cce3fe SEED(0.0) CN:15 SD:4]
10/28 19:15:10 [NOTICE] Download complete: /tmp/ktails.upawW2/tails-amd64-4.0-img

10/28 19:15:10 [NOTICE] Your share ratio was 0.0, uploaded/downloaded=0B/1.0GiB

Download Results:
gid   |stat|avg speed  |path/URI
======+====+===========+=======================================================
2ec567|OK  |    41MiB/s|/tmp/ktails.upawW2/tails-amd64-4.0.img.torrent
cce3fe|OK  |    20MiB/s|/tmp/ktails.upawW2/tails-amd64-4.0-img/tails-amd64-4.0.img (1more)

Status Legend:
(OK):download completed.
2129817 blocks
!! loading Tails...
!! kexecing Tails...

# screen will corrupt
# computer will reboot into Tails
```
