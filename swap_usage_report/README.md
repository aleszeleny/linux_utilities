# swap_usage_report.sh
Script to report processes using SWAP on linux.

```
Usage: List swap space usage by processes
swap_usage_report.sh [-h|--help] [-p|sort-pid] [-s|--sort-size] [-n|--sort-name] [ -r|--reverse]
B | size-in-bytes	print swap used space in Bytes
h | help		print this usage help
n | sort-name		Sort processes by name
p | sort-pid		Sort process using swap ordered by PID
q | quiet		Print only process rows (no header, no summary)
r | reverse		Reverse sort
s | sort-size		Sort processes by swap space used space (default)
```

## Examples

### Default report
```
$ ./swap_usage_report.sh 
========================================
Sort by swap space used
----------------------------------------
   PID Swap size  Process name
========================================
104870     60KiB  slack
 37785    120KiB  firefox
104901    244KiB  slack
  5047    280KiB  dbus-broker
 26290    456KiB  evinced
...
  5566    338MiB  dropbox
  5245    533MiB  gnome-software
========================================
Overall swap used:  1.7GiB
```
The default report is equivalent to `./swap_usage_report.sh -s`

### Report sorted by used SWAP size in reverse order
```
 ./swap_usage_report.sh -r
========================================
Sort by swap space used
----------------------------------------
   PID Swap size  Process name
========================================
  5245    533MiB  gnome-software
  5566    336MiB  dropbox
 26284    171MiB  evince
 14622    106MiB  skypeforlinux
...
 37785    120KiB  firefox
104870     60KiB  slack
========================================
Overall swap used:  1.7GiB
```
The default report is equivalent to `./swap_usage_report.sh -sr`

### Report sorted by process name in reverse order printing used SWAP space in Bytes
```$ ./swap_usage_report.sh -nBr
========================================
Swap space usage in Bytes
Sort by process name
----------------------------------------
   PID      Swap size  Process name
========================================
  5015       21032960  Xwayland
  5082        1220608  xdg-permission-
  5306       11739136  tracker-miner-f
  4831        2154496  systemd
...
  8254        4423680  bash
  5041         782336  at-spi-bus-laun
  5221         851968  at-spi2-registr
  5302        4235264  abrt-applet
========================================
Overall swap used:   1757159424
```

### Report sorted by PID in quiet mode with swap space reported in Bytes
This report output is intended to be suitable for use by other scripts, though sort column is most proably not important in such case.
```
$ ./swap_usage_report.sh -pBq
  4831        2154496  systemd
  4846        3768320  pulseaudio
...
104870          61440  slack
104901         249856  slack
```
