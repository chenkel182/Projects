#!/bin/bash

set -e

cd /tmp && wget https://packages.chef.io/files/stable/chef-server/12.19.26/el/7/chef-server-core-12.19.26-1.el7.x86_64.rpm
rpm -i /tmp/chef-server-core-12.19.26-1.el7.x86_64.rpm
chef-server-ctl reconfigure
chef-server-ctl user-create ${chef_username} ${chef_user} ${chef_user_email} ${chef_password} --filename /tmp/stack.pem
chef-server-ctl org-create ${chef_organization_id} "${chef_organization_name}" --association_user ${chef_username} --filename /tmp/stack-validator.pem
mkdir -p /etc/opscode/
chef-server-ctl install chef-manage
chef-server-ctl reconfigure
chef-manage-ctl reconfigure --accept-license
chef-server-ctl install opscode-reporting
chef-server-ctl reconfigure
opscode-reporting-ctl reconfigure --accept-license
chef-server-ctl reconfigure
echo "nginx[\"enable_non_ssl\"] = true" > /etc/opscode/chef-server.rb
chef-server-ctl reconfigure
echo "Finished"
