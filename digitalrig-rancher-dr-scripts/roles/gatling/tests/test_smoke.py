import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')


def test_symlink_creation(File):
    gatling_path = "/opt/gatling-charts-highcharts-bundle"

    gatling_file = File(gatling_path)
    assert gatling_file.linked_to == gatling_path + '-2.2.2'
    assert gatling_file.user == "root"
    assert gatling_file.group == "root"
