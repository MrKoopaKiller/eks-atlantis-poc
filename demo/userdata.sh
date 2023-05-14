#!/bin/bash
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILz4ggmplSztSEMuyHEovNKyrKmycefUlxJkVezExata koopa@killer.local' > /home/ec2-user/.ssh/authorized_keys
chown ec2-user:ec2-user /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
