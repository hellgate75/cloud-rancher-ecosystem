import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')


def test_web_server_is_listening(Socket):
    assert Socket("tcp://:::8888").is_listening
