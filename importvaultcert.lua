function run(cmd)
	local file = assert(io.popen(cmd))
	local output = file:read('*a')
	local success, _, code = file:close()
	return output, success, code
end

function urldecode(s)
	s = s:gsub('+', ' ')
	:gsub('%%(%x%x)', function(h)
		return string.char(tonumber(h, 16))
	end)
	return s
end

local function isempty(s)
  return s == nil or s == ''
end

function parseqs(s)
	local ans = {}
	for k,v in s:gmatch('([^&=?]-)=([^&=?]+)' ) do
		ans[ k ] = urldecode(v)
	end
	return ans
end

core.register_service("importvaultcert", "http", function(applet)
	local output, success, code
	if isempty(applet.qs) then
		output, success, code = run("/marathon-lb/import-certs-from-vault.sh", false)
	else
		local qs = parseqs(applet.qs)
		output, success, code = run("/marathon-lb/import-certs-from-vault.sh " ..  qs.fqdn, false)
	end
	if not success then
		send_response(applet, 500, string.format(
			"Failed to import cert %s : %s", fqdn, output))
		return
	end

	applet:set_status(200)
	applet:add_header("content-length", string.len(output))
	applet:add_header("content-type", "text/plain")
	applet:start_response()
	applet:send(output)
end)
