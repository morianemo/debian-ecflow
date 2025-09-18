##!/usr/bin/env python3
""" suite navigation, starter """
import os
import ecflow


def process(node):
    if isinstance(node, ecflow.Task):
        print("a task", node.name())
    elif isinstance(node, ecflow.Family):
        print("a family", node.name())
    elif isinstance(node, ecflow.Suite):
        print("a suite", node.name())
    elif isinstance(node, ecflow.Alias):
        print("an alias")
    else:
        print("???")
    print(node.get_abs_node_path(), node.get_state(),
          "T:", node.get_trigger(), "C:", node.get_complete())
    for kid in node.nodes:
        process(kid)

if __name__ == '__main__':
    CLIENT = ecflow.Client(os.getenv('ECF_HOST', "localhost"),
                           os.getenv('ECF_PORT', "3141"))
    CLIENT.ch_register(False, ["elearning", ])
    CLIENT.sync_local()
    DEFS = CLIENT.get_defs()

    for item in DEFS.suites:
        process(item)
