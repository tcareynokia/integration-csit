import json

import docker
import time


class BbsLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def check_for_log(search_for):
        client = docker.from_env()
        container = client.containers.get('bbs-event-processor')

        alog = container.logs(stream=False, tail=1000)
        try:
            alog = alog.decode()
        except AttributeError:
            pass

        found = alog.find(search_for)
        if found != -1:
            return True
        else:
            return False

    @staticmethod
    def create_auth_policy(json_file):
        json_to_python = json.loads(json_file)
        str_json = json_to_python
        """
        ipv4 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV4IpAddress")
        ipv6 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") if "oamV6IpAddress" in json_to_python["event"]["pnfRegistrationFields"] else ""
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")
        str_json = '{"correlationId":"' + correlation_id + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '"}'
        """
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

    @staticmethod
    def create_invalid_auth_policy(json_file):
        return BbsLibrary.create_auth_policy(json_file)

    @staticmethod
    def create_pnf_name_from_auth(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")
        return correlation_id

    @staticmethod
    def compare_policy(dmaap_policy, json_policy):
        resp = False
        try:
            python_policy = json.loads(json_policy).pop()
        except:
            python_policy = ""
        
        try:
            python_dmaap_policy = json.loads(dmaap_policy).pop()
        except:
            python_dmaap_policy = ""

        try:
            d_policy = python_dmaap_policy.get("policyName")
        except:
            d_policy = ""

        try:
            j_policy = python_policy.get("policyName")
        except:
            return "False"
        
        resp = "False"
        if (d_policy == j_policy):
            resp = "True"
        return resp

    @staticmethod
    def create_update_policy(json_file):
        json_to_python = json.loads(json_file)
        str_json = json_to_python
        """
        ipv4 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV4IpAddress")
        ipv6 = json_to_python.get("event").get("pnfRegistrationFields").get("oamV6IpAddress") if "oamV6IpAddress" in json_to_python["event"]["pnfRegistrationFields"] else ""
        correlation_id = json_to_python.get("event").get("commonEventHeader").get("sourceName")
        str_json = '{"correlationId":"' + correlation_id + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '"}'
        """
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

    @staticmethod
    def create_invalid_update_policy(json_file):
        return BbsLibrary.create_update_policy(json_file)

    @staticmethod
    def create_pnf_name_from_update(json_file):
        json_to_python = json.loads(json_file)
        correlation_id = json_to_python.get("correlationId")
        return correlation_id

    @staticmethod
    def ensure_container_is_running(name):
        client = docker.from_env()

        if not BbsLibrary.is_in_status(client, name, "running"):
            print ("starting container", name)
            container = client.containers.get(name)
            container.start()
            BbsLibrary.wait_for_status(client, name, "running")

        BbsLibrary.print_status(client)

    @staticmethod
    def ensure_container_is_exited(name):
        client = docker.from_env()

        if not BbsLibrary.is_in_status(client, name, "exited"):
            print ("stopping container", name)
            container = client.containers.get(name)
            container.stop()
            BbsLibrary.wait_for_status(client, name, "exited")

        BbsLibrary.print_status(client)

    @staticmethod
    def print_status(client):
        print("containers status")
        for c in client.containers.list(all=True):
            print(c.name, "   ", c.status)

    @staticmethod
    def wait_for_status(client, name, status):
        while not BbsLibrary.is_in_status(client, name, status):
            print ("waiting for container: ", name, "to be in status: ", status)
            time.sleep(3)

    @staticmethod
    def is_in_status(client, name, status):
        return len(client.containers.list(all=True, filters={"name": "^/"+name+"$", "status": status})) == 1

