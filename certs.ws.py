#!/usr/bin/env python3

import http.server # Our http server handler for http requests
import socketserver # Establish the TCP Socket connections
import json
import subprocess
import os

class RequestHandler(http.server.BaseHTTPRequestHandler):

    def do_POST(self):
        uriparts = self.path.split('/')
        args = ['/marathon-lb/import-certs-from-vault.sh']

        if len(uriparts) == 3:
           args.append(uriparts[2])
        
        try:
            b = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=True )
            self.send_response(200)
            self.end_headers()
            self.wfile.write(json.dumps({'stdout': b.stdout.decode("utf-8") }).encode())
        except subprocess.CalledProcessError as e:
            self.send_response(500)
            self.end_headers()
            self.wfile.write(json.dumps({'error': e.stdout.decode("utf-8") }).encode())
 
Handler = RequestHandler
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("127.0.0.1", 3000), Handler) as httpd:
    httpd.serve_forever()
