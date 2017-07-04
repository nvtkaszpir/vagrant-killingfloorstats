#!/usr/bin/env bash
# all input argments should be in form key=val
echo "Running facter scripts"
mkdir -p /etc/facter/facts.d/
rm -f /etc/facter/facts.d/vagrant.txt
for kv in "$@"
do
	echo "Addinng $kv"
	echo "$kv" >> /etc/facter/facts.d/vagrant.txt
done

echo "/etc/facter/facts.d/vagrant.txt"
cat /etc/facter/facts.d/vagrant.txt
