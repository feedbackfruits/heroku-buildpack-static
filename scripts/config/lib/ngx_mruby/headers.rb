# ghetto require, since mruby doesn't have require
eval(File.read('/app/bin/config/lib/nginx_config_util.rb'))

USER_CONFIG = "/app/static.json"

config = {}
config = JSON.parse(File.read(USER_CONFIG)) if File.exist?(USER_CONFIG)
req    = Nginx::Request.new
uri    = req.var.uri

if config["headers"]
  config["headers"].to_a.reverse.each do |route, header_hash|
    if Regexp.compile("^#{NginxConfigUtil.to_regex(route)}$") =~ uri
      req.headers_out.all.keys.each do |k|
        Nginx.echo "#{k}: #{req.headers_out[k]}"
      end
      header_hash.each do |key, value|
        # value must be a string
        req.headers_out[key] = value.to_s unless req.headers_out['status'] == 404
      end
      break
    end
  end
end
