#!/bin/bash -x

filename=${0##*/}
echo "`date +%F\ %H:%M:%S.%N`: [INFO] Invoking $filename" > /var/tmp/post-install-${filename}.log
exec >> /var/tmp/post-install-${filename}.log 2>&1

USER=ubuntu
mkdir -p /home/$USER/.ssh
cat >> /home/$USER/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqr5YHPYgJJwHRfw1+ySMoees2KAj4o3JCSc66PR1p8iZaAMAKNn7Z5XP03KLiu0UKZx8ceLWMY+fy7kE5pEVAjhqHxwBUjbdj32gDbTqX059dTF+UzTFZNxpZNA1nU9p5f4YqJeLrxLL0I7P/LVYLTaFTQYDwMYRBLmk3X3kQFyRLF6bKHrTkW8dBQeHPxhCdqlupj3uLyBcTR2qBaQrfCPvYP+9Bu2QfgMA8ex9YHfAzM8mAsgn1OxPEXe2KRIZZYo0vS3vLBRm7mmscWv6jxsw/GJd/0awKUyh6Yfw9U5Jry3neH7vuO7L6rmpPn3r3sTlLtijMfCUGCzDO2Vr+w== PVeretennikovs@riskfocus.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCtsP5tluFyVEtO7zc1A6nZOc9dLYFoqL2dOHH1/ymbq5UY+i2GVSRxxKA7uJdDd/F4/A9zwBShPrRS/Efd5LMmSe0R1h6LCuIzbFT54WdVfnkQLdCDCNfrbEBX2JLybqWFswzmP17Hi8bqkt+jwpEEAJ23+oOS7YdnpwkRL6OLvyRRUIoAPk/uXnZ0mYW3TdM5q3TRWhpXyUheHLLmFFk4Wpns1b5CM+xMTlHlyUKue387fhrlpn7td5NDoZqK3R/Wh/5c4+2J16HWxRFi7UqjL39YWWztUoHkJuOhNNmiAxe8ucES98GpSfwUwfUoActx2fDF5p6KqUcgrtymk5cZ
EOF

# Change ownership and access modes for the new directory/file
chown -R $USER:$USER /home/$USER/.ssh
chmod -R go-rx /home/$USER/.ssh
