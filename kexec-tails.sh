#!/usr/bin/env bash
set -euo pipefail

if ! which aria2c ; then
  printf "warn: 'aria2c' is recommended" >2; exit -1
  if ! which wget ; then
    printf "error: 'aria2c' or 'wget' is required" >2; exit -1
  fi
fi

if ! which 7z || ! which cpio ; then
  printf "error: 'p7zip (7z)' and 'cpio' are required" >2; exit -1
fi

# fetch upstream info
index="https://tails.boum.org/install/v2/Tails/amd64/stable/latest.json"
ver="$(curl --silent "${index}" | jq -r ".installations[0].version")"
fname="tails-amd64-${ver}.img"

# temp workdir
OUTDIR="$(mktemp -d "/tmp/ktails.XXXXXX")";
trap "rm -rf ${OUTDIR}" EXIT
img="${OUTDIR}/${fname}"

# outputs
mkdir -p "${HOME}/.cache/ktails/"
KERNEL="${HOME}/.cache/ktails/${fname}.vmlinuz"
INITRD="${HOME}/.cache/ktails/${fname}.initrd.gz"

function acquire_img() {
  if which aria2c ; then
    aria2c --dir="${OUTDIR}" --seed-time=0 \
      "https://tails.boum.org/torrents/files/${fname}.torrent"
    mv "${OUTDIR}/tails-amd64-${ver}-img/${fname}" "${img}"
  else
    wget -O "${img}" \
      "http://dl.amnesia.boum.org/tails/stable/tails-amd64-${ver}/${fname}"
  fi
}

function build_payload() {
  # extract relevant files from the full image
  7z x -o"${OUTDIR}" "${img}" \
    live/filesystem.squashfs live/initrd.img live/vmlinuz >/dev/null

  # cpio the squashfs on the end of the initrd
  echo live$'\n'live/filesystem.squashfs \
    | cpio -o -H newc -D "${OUTDIR}" \
      >> "${OUTDIR}/live/initrd.img"

  # mv them into the cached location for future
  mv "${OUTDIR}/live/vmlinuz" "${KERNEL}"
  mv "${OUTDIR}/live/initrd.img" "${INITRD}"
}

if [[ ! -f "${INITRD}" || ! -f "${KERNEL}" ]]; then
  if [[ ! -f "${img}" ]]; then
    acquire_img
  fi

  build_payload
fi

# in case of memory pressure
rm -rf "${OUTDIR}"

CMDLINE="console=tty0 console=ttyS0"
CMDLINE="${CMDLINE} boot=live config live-media=removable nopersistence module=Tails"
CMDLINE="${CMDLINE} timezone=Etc/UTC noprompt noautologin"
CMDLINE="${CMDLINE} block.events_dfl_poll_msecs=1000"
CMDLINE="${CMDLINE} slab_nomerge slab_debug=FZP page_poison=1 mds=full,nosmt"
CMDLINE="${CMDLINE} mce=0 vsyscall=none union=aufs"
CMDLINE="${CMDLINE} live-media=/ toram"

sudo kexec --load --initrd "${INITRD}" --command-line "${CMDLINE}" "${KERNEL}"
sudo kexec --reset-vga --exec
