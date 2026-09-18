# Synology ABB for CachyOS

This is an AUR submission-ready split package. It creates:

- `synology-active-backup-business-agent` — vendor userspace and systemd unit
- `synosnap-dkms` — changed-block tracking module rebuilt by DKMS for each CachyOS kernel update

It does not redistribute Synology binaries. Before building, download the official x86_64 RPM ZIP matching `pkgver` from Synology's Download Center and place it beside `PKGBUILD` with the exact filename specified in `source=`, then run `makepkg -si`.

The module source comes from Peppershade's Linux 7.0 compatibility work at a pinned commit. `cachyos-7.2.patch` adds the Arch System.map location, makes clang feature probes reliable, replaces removed `strncpy` calls, and moves KASLR-relative symbol calculations out of static initializers, which Linux 7.2 CachyOS's clang configuration rejects.

The package intentionally runs `dkms autoinstall` without suppressing errors. A failed module build is therefore visible and fails the package scriptlet. DKMS's normal pacman hook rebuilds it after `linux-cachyos` updates.

Validation after install:

```sh
dkms status
sudo modprobe synosnap
sudo dmesg --level=err,warn | tail -n 100
systemctl status synology-active-backup-business
```

Connect the agent from Active Backup for Business on the NAS, take a small backup, then confirm the next one is incremental.

## GitHub Actions and AUR publishing

`build.yml` runs on `main` and only runs a pull-request job when the PR is from a branch in this repository and both the author and actor are the repository owner. Fork PRs never receive a runner or secrets. Set `ABB_RPM_URL` as a repository secret containing a direct, official Synology RPM ZIP URL; it is used only for private build jobs and is never committed or uploaded.

`publish-aur.yml` is manual only. Create a protected GitHub environment named `aur`, restrict it to yourself, and add the `AUR_SSH_PRIVATE_KEY` repository secret containing an AUR deploy key. Invoke the workflow as the repository owner and type `PUBLISH`; it regenerates no binaries, only pushes the AUR packaging sources.

## Secure Boot

DKMS 3 signs modules at build time when `try_sign_modules` is enabled (its default outside chroots). It keeps the key material local under `/var/lib/dkms`; no private key is stored in this repository or GitHub Actions. With Secure Boot enabled, install `mokutil`, run `sudo synosnap-enroll-mok`, enroll the certificate in MokManager on the following boot, then run `sudo modprobe synosnap`. Existing MOK material can instead be selected using `mok_signing_key` and `mok_certificate` in `/etc/dkms/framework.conf.d/*.conf`.
