apt_repository 'nodejs' do
  uri 'http://ppa.launchpad.net/chris-lea/node.js/ubuntu'
  distribution node['lsb']['codename']
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'C7917B12'
end

package 'nodejs'

#npm_package 'forever'

# directory '/srv/www/.forever' do
#   owner 'www-data'
#   group 'www-data'
#   mode 02755
#   recursive true
# end