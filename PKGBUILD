pkgbase=synology-active-backup-business-agent
pkgname=(synology-active-backup-business-agent synosnap-dkms)
pkgver=3.1.0_4967
pkgrel=1
pkgdesc='Synology Active Backup for Business Agent, with a CachyOS 7.2 synosnap DKMS module'
arch=(x86_64)
url='https://www.synology.com/'
license=(custom)
depends=(bash glibc systemd-libs)
makedepends=(git libarchive unzip)
source=(
  "Synology Active Backup for Business Agent-${pkgver/_/-}-x64-rpm.zip::https://global.synologydownload.com/download/Utility/ActiveBackupBusinessAgent/${pkgver/_/-}/Linux/x86_64/Synology%20Active%20Backup%20for%20Business%20Agent-${pkgver/_/-}-x64-rpm.zip"
  'synosnap-source::git+https://github.com/Peppershade/abb-linux-agent.git#commit=d04e7ee2467005e5eee73ddaf6e4d33d50ddfcef'
  cachyos-7.2.patch
  synosnap-dkms.conf
  synosnap-enroll-mok
)
sha256sums=('78a10a90800ca9f9b613558fafc04d4bcf6d726adef07ded2d0f576bd48c8f27' SKIP SKIP SKIP SKIP)
_synosnapver=0.12.12

prepare() {
  local installer rpm

  installer=$(find "$srcdir" -maxdepth 2 -type f -name '*.run' -print -quit)
  if [[ -z $installer ]]; then
    printf '%s\n' 'The official Synology RPM installer was not found after extracting the ZIP.' >&2
    return 1
  fi

  chmod +x "$installer"
  "$installer" --accept --noexec --keep --nox11 --nochown --target "$srcdir/abb-payload"
  mkdir -p "$srcdir/abb-root"
  while IFS= read -r -d '' rpm; do
    bsdtar -xf "$rpm" -C "$srcdir/abb-root"
  done < <(find "$srcdir/abb-payload" -type f -name '*.rpm' -print0)

  cp -a "$srcdir/synosnap-source/build-tools/patches/synosnap" "$srcdir/synosnap-${_synosnapver}"
  patch -d "$srcdir/synosnap-${_synosnapver}" -p4 < "$srcdir/cachyos-7.2.patch"
  install -Dm644 "$srcdir/synosnap-dkms.conf" "$srcdir/synosnap-${_synosnapver}/dkms.conf"
}

package_synology-active-backup-business-agent() {
  depends+=(synosnap-dkms)

  for dir in etc opt usr var; do
    [[ -d $srcdir/abb-root/$dir ]] && cp -a "$srcdir/abb-root/$dir" "$pkgdir/"
  done

  # The vendor RPM's module and RPM-maintainer scripts are replaced by the
  # separately managed DKMS package below.
  rm -rf "$pkgdir/usr/src" "$pkgdir/opt/synosnap" "$pkgdir/etc/kernel" \
    "$pkgdir/usr/lib/kernel" "$pkgdir/usr/lib/synosnap"

  install -d "$pkgdir/usr/bin"
  ln -sf /opt/Synology/ActiveBackupforBusiness/bin/synology-backupd "$pkgdir/opt/Synology/ActiveBackupforBusiness/bin/abb-cli"
  install -Dm755 /dev/stdin "$pkgdir/usr/bin/abb-cli" <<'EOF'
#!/bin/bash
export LD_LIBRARY_PATH=/opt/Synology/ActiveBackupforBusiness/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
exec /opt/Synology/ActiveBackupforBusiness/bin/abb-cli "$@"
EOF

  install -Dm644 \
    "$pkgdir/opt/Synology/ActiveBackupforBusiness/data/synology-active-backup-business-linux-service.service" \
    "$pkgdir/usr/lib/systemd/system/synology-active-backup-business.service"
  sed -i '/^\[Service\]$/a Environment=LD_LIBRARY_PATH=/opt/Synology/ActiveBackupforBusiness/lib' \
    "$pkgdir/usr/lib/systemd/system/synology-active-backup-business.service"
  install -Dm644 "$srcdir/abb-payload/README" "$pkgdir/usr/share/doc/$pkgname/README" 2>/dev/null || true
}

package_synosnap-dkms() {
  pkgdesc='Synology synosnap changed-block tracking kernel module (DKMS; CachyOS 7.2)'
  depends=('dkms>=3.0' linux-cachyos-headers clang llvm)
  optdepends=('mokutil: enroll the local DKMS signing certificate for Secure Boot')
  provides=("synosnap=${_synosnapver}")
  conflicts=(synosnap)
  install=synosnap-dkms.install

  install -d "$pkgdir/usr/src"
  cp -a "$srcdir/synosnap-${_synosnapver}" "$pkgdir/usr/src/synosnap-${_synosnapver}"
  install -Dm755 "$srcdir/synosnap-enroll-mok" "$pkgdir/usr/bin/synosnap-enroll-mok"
}
