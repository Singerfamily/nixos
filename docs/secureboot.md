# Lanzaboote

`sudo sbctl create-keys`

`sudo sbctl enroll-keys`

`sudo systemd-cryptenroll --tpm2-device=auto --tpm2-with-pin=false --tpm2-pcrs=0+2+7 /dev/disk/by-uuid/<DISK UUID>`
