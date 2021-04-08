#! /bin/sh

wg genkey | tee $1.privatekey | wg pubkey > $1.publickey
