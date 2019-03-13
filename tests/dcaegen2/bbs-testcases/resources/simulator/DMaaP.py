import re
import time
from http.server import BaseHTTPRequestHandler
import httpServerLib

posted_event_from_bbs = b'Empty'
received_event_to_get_method = b'Empty'


class DmaapSetup(BaseHTTPRequestHandler):

    def do_PUT(self):
        if re.search('/set_get_event', self.path):
            global received_event_to_get_method
            content_length = int(self.headers['Content-Length'])
            received_event_to_get_method = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)

        return

    def do_GET(self):
        # Get the CPE Authentication Policy trigger
        if re.search('/events/pnfReady', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(posted_event_from_bbs)
        # Get the PNF Update Policy trigger
        elif re.search('/events/pnfReady', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(posted_event_from_bbs)

        return

    def do_POST(self):
        if re.search('/reset', self.path):
            global posted_event_from_bbs
            global received_event_to_get_method
            posted_event_from_bbs = b'Empty'
            received_event_to_get_method = b'Empty'
            httpServerLib.header_200_and_json(self)

        return


class DMaaPHandler(BaseHTTPRequestHandler):

    def do_POST(self):
        # Post the CPE Authentication Policy trigger
        if re.search('/events/unauthenticated.PNF_READY', self.path):
            global posted_event_from_bbs
            content_length = int(self.headers['Content-Length'])
            posted_event_from_bbs = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)
        # Post the PNF Update Policy trigger
        elif re.search('/events/unauthenticated.PNF_READY', self.path):
            global posted_event_from_bbs
            content_length = int(self.headers['Content-Length'])
            posted_event_from_bbs = self.rfile.read(content_length)
            httpServerLib.header_200_and_json(self)

        return

    def do_GET(self):
        # Get the CPE Authentication event
        if re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)
        # Get the PNF Update event
        elif re.search('/events/unauthenticated.VES_PNFREG_OUTPUT/OpenDcae-c12/c12', self.path):
            httpServerLib.header_200_and_json(self)
            self.wfile.write(received_event_to_get_method)

        return


def _main_(handler_class=DMaaPHandler, protocol="HTTP/1.0"):
    handler_class.protocol_version = protocol
    httpServerLib.start_http_endpoint(2222, DMaaPHandler)
    httpServerLib.start_https_endpoint(2223, DMaaPHandler, keyfile="certs/org.onap.dmaap-bc.key", certfile="certs/dmaap_bc_topic_mgr_dmaap_bc.onap.org.cer", ca_certs="certs/ca_local_0.cer")
    httpServerLib.start_http_endpoint(2224, DmaapSetup)
    while 1:
        time.sleep(10)


if __name__ == '__main__':
    _main_()
