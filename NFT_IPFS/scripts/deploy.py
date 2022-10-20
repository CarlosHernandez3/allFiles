# pylint: disable=no-name-in-module

from brownie import accounts, network, config, RandomIpfsNft
from scripts.helpful_scripts import fund_with_link, get_publish_source


def main():
    dev = accounts.add(config["wallets"]["from_key"])
    print(network.show_active())
    Random_IpfsNft = RandomIpfsNft.deploy(
        config["networks"][network.show_active()]["vrf_coordinator"],
        config["networks"][network.show_active()]["link_token"],
        config["networks"][network.show_active()]["keyhash"],
        {"from": dev},
        publish_source=get_publish_source(),
    )
    fund_with_link(Random_IpfsNft.address)
    return Random_IpfsNft
