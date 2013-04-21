This is a handy ruby script used for remote backups over ssh.

1. reads a list of servers and directories from a yaml file 
2. mirrors them to the current directory via rsync 
3. runs rdiff-backup (http://rdiff-backup.nongnu.org/) creating a rdiff-backup directory which can be queried for incremental backups

