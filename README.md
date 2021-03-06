## Simple FreeBSD/*nix Server Monitoring
Simple monitoring of core measurements on *nix OS: statistics in CSV files and dynamic graphs (dygraph) in HTML. 
No special databases or plugins. Simple HTML file that includes CSV files through JavaScript - very fast and no dynamic content. Plots can be zoomed both X- and Y-wise.
Current configuration includes 7 days statistic: 10,080 measurements = 7 days * 24 hours * 60 minutes.

## Installation
No special procedures, place HTML file in the web-server folder and run Bash script regularly to gather statistic.

## Measurements

![Screenshot](screenshots/screenshot1.png)

![Screenshot](screenshots/screenshot2.png)

## Dependencies
- Dygraph (included online)
- uptime
- awk
- sysctl
- tr
- smartctl
- grep
- touch
- netstat
- ifstat
- top
- sed
- cat

Eventual tuning is required depending on the system

## Cron
Every 1 minute, HDD polling - 10 minutes due to latency

\* \* \* \* \* update_mon.sh   2>&1
