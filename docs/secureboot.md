# Secure Boot + TPM2 Setup (Lanzaboote)

This covers initial setup for UEFI Secure Boot with lanzaboote and TPM2 auto-unlock for LUKS.
Run these steps once after first boot on a new machine. The `lanzaboote` aspect must be included
in the host before starting.

## Prerequisites

Verify lanzaboote is active:

```bash
bootctl status   # should show "Secure Boot: disabled (setup mode)"
sbctl status     # should show "Setup Mode: Enabled"
```

If not in Setup Mode, enter UEFI firmware and clear/reset Secure Boot keys.

## Step 1: Create and Enroll Secure Boot Keys

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft   # include Microsoft keys for driver compatibility
```

Reboot. After reboot, verify:

```bash
sbctl status   # should show "Secure Boot: enabled", "Secure Boot Mode: user"
```

## Step 2: Enroll LUKS Disk in TPM2

This binds LUKS auto-unlock to PCR 7 (Secure Boot state), so the disk only auto-unlocks
when booting with your enrolled keys. Find the disk UUID first:

```bash
lsblk -o NAME,UUID   # find the UUID of your encrypted LUKS partition
```

Then enroll:

```bash
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=false --tpm2-pcrs=0+2+7 /dev/disk/by-uuid/<DISK UUID>
```

Reboot to confirm the disk unlocks automatically without a passphrase prompt.

## Troubleshooting

**Secure Boot breaks after a kernel update**: lanzaboote signs kernels automatically on rebuild.
If a kernel update fails to sign, boot with the passphrase and run `sudo nixos-rebuild switch`.

**TPM auto-unlock stops working after firmware update**: PCR 0 (firmware measurements) will
have changed. Re-enroll: wipe the old TPM slot first, then re-run Step 2.

```bash
sudo systemd-cryptenroll --wipe-slot=tpm2 /dev/disk/by-uuid/<DISK UUID>
sudo systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=false --tpm2-pcrs=0+2+7 /dev/disk/by-uuid/<DISK UUID>
```

**Locked out (forgot passphrase + TPM not working)**: You need a recovery key. Add one before
this happens:

```bash
sudo systemd-cryptenroll --recovery-key /dev/disk/by-uuid/<DISK UUID>
```
