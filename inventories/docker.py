#!/usr/bin/env python

from copy import deepcopy
from json import dumps

from docker import DockerClient


class DockerInventory(object):
    """Docker inventory class.

    This class will generate the data structure needed by ansible inventory
    host for either all containers on your system or the one you declare. The
    data structure generated is in JSON format.
    """

    _data_structure = {'all': {'hosts': []}, '_meta': {'hostvars': {}}}

    def __init__(self):
        """Constructor.

        When the docker inventory class is instanticated, it performs the
        following tasks:
            * Instantiate the docker client class to create a docker object.
            * Generate the JSON data structure.
            * Print the JSON data structure for ansible to use.
        """
        self.docker = DockerClient()

        data = self.containers()
        print(dumps(data))

    def get_containers(self):
        """Return all docker containers on the system.

        :return: Collection of containers.
        """
        return self.docker.containers.list(all=False)

    def containers(self):
        """Return all docker containers to be used by ansible inventory host.

        :return: Ansible required JSON data structure with containers.
        """
        resdata = deepcopy(self._data_structure)
        for container in self.get_containers():
            resdata['all']['hosts'].append(container.name)
            resdata['_meta']['hostvars'][container.name] = \
                {'ansible_connection': 'docker'}

        return resdata

if __name__ == "__main__":
    DockerInventory()
