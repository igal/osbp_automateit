# Setup attendee wiki.
# NOTE Apache site is managed by the 'my_bridgepdx_wordpress' recipe.

user = "bridgepdx"

# Install dependencies
package_manager.install <<-HERE
  php5-gmp
  php5-curl
HERE

# Create directory
path = "/var/www/bridgepdx_wiki"
mkdir_p(path) and chperm(path, :user => "bridgepdx", :group => "bridgepdx")

# Install PHP OpenID library, downloaded from http://openidenabled.com/php-openid/
### FIXME AutomateIt is getting confused because it sees two "//"s and thus isn't matching
# path = "/usr/share/php/Auth"; cp(dist+path, path)
### Workaround:
path = "usr/share/php/Auth"; cp(dist+path, "/"+path)

# Add program that can dump database to file
cpdist("/var/www/bridgepdx_wiki/Rakefile")

# Add task to dump database to file
edit("/var/spool/cron/crontabs/#{user}", :create => true, :user => user, :group => "crontab", :mode => 0600) do
  append "# m h  dom mon dow   command"
  delete "17 * * * * (cd /var/www/bridgepdx_wiki && rake --silent dump)"
  delete "18 * * * * if test -f /var/www/bridgepdx_wiki/Rakefile; then (cd /var/www/bridgepdx_wiki && rake --silent dump); fi"
  append "18 * * * * if test -f /var/www/bridgepdx_wiki/LocalSettings.php; then (cd /var/www/bridgepdx_wiki && rake --silent dump); fi"
end
