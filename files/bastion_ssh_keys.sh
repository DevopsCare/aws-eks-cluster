
#
# Copyright (c) 2020 Risk Focus Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

#!/bin/bash -x

filename=${0##*/}
echo "`date +%F\ %H:%M:%S.%N`: [INFO] Invoking $filename" > /var/tmp/post-install-${filename}.log
exec >> /var/tmp/post-install-${filename}.log 2>&1

USER=ubuntu
mkdir -p /home/$USER/.ssh
cat >> /home/$USER/.ssh/authorized_keys << 'EOF'
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqr5YHPYgJJwHRfw1+ySMoees2KAj4o3JCSc66PR1p8iZaAMAKNn7Z5XP03KLiu0UKZx8ceLWMY+fy7kE5pEVAjhqHxwBUjbdj32gDbTqX059dTF+UzTFZNxpZNA1nU9p5f4YqJeLrxLL0I7P/LVYLTaFTQYDwMYRBLmk3X3kQFyRLF6bKHrTkW8dBQeHPxhCdqlupj3uLyBcTR2qBaQrfCPvYP+9Bu2QfgMA8ex9YHfAzM8mAsgn1OxPEXe2KRIZZYo0vS3vLBRm7mmscWv6jxsw/GJd/0awKUyh6Yfw9U5Jry3neH7vuO7L6rmpPn3r3sTlLtijMfCUGCzDO2Vr+w== PVeretennikovs@riskfocus.com
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDDq+HgbzBw5YwiEgMK5YUMaSz+kYKiS5vAdtHXI/zuRnqCg47RCCKgVwYYDBH8HjB4bUVocbEP+kGgDSX+qDdle9r9UVk1VExDNTfSoytj4gUamU/ejNY+D3LYE3sEcA481mzr2k6M7UnY/jLPwcnEMqlfW7qvaQ18QbIwwpVBA+VTaHAcuL7vG5NkHPxD3ZfEQX+kIXTau4bkbkIyqVv9Pdpgg9e7nRVu1jIzlUWO7CeDRgBfwl9c9koWqVOUYeLa2n/HCWig2ACyzav5LBHV8FamRWNYqBTjcOkG4n7e3Ss9O86oNPM4HFTfEsrBgSHsKA55HNI+GlmHUH4yLTLtf95T9xdFe5qztPNVjs6EuCZ0KpwayyeNjX30TNnpg4hPlNwA0+/+p9aLdrKXw+t5EFThvmU1r2bwI3FJkj3hBF8W7XoSRUBIdtxTNFSGmws7lpgYInxw6qv7Ne6wiOBXuxPM+2PbFvde4b0gU6y07mWdmjReDQxdC3kL9sjVafaeib7BXx4YqUgM/6AWOEcjqOqeR4ehMN+OzLJx2La/vewibdkTPi4ElVXVE02wFmiDAfkT9mBLTdwbUd0E/AYXfUc0oMznsh86qGccYwphlyxOL2VOScPL2gZWevIj/o7BFAmMstL3Fx0GUrg7YVVjP323vXVE7v5c2HVid1H7/w== vkropotko@rfe034.local
EOF

# Change ownership and access modes for the new directory/file
chown -R $USER:$USER /home/$USER/.ssh
chmod -R go-rx /home/$USER/.ssh
