#! /bin/sh

tc qdisc add dev $DEV root handle 1: cbq avpkt 1000 bandwidth 10mbit 

tc class add dev $DEV parent 1: classid 1:1 cbq rate 512kbit \
	allot 1500 prio 5 bounded isolated 

tc filter add dev $DEV parent 1: protocol ip prio 16 u32 \
	match ip dst $IP flowid 1:1
