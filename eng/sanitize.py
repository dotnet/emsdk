#!/usr/bin/env python3
import json
import os
import shutil
import sys


def glob(path):
    return [os.path.join(path, filename) for filename in os.listdir(path)]


def rewrite_package_json(path):
    package = open(path, "r+")
    settings = json.load(package)
    settings["devDependencies"] = {}
    package.seek(0)
    package.truncate()
    json.dump(settings, package, indent=4)
    package.close()


def prune(path):
    try:
        os.chdir(path)
        os.system("npm prune --production")
    except OSError as error:
        print("npm prune failed")
        print(error)


def auditfix(path):
    try:
        os.chdir(path)
        os.system("npm audit fix")
    except OSError as error:
        print("npm audit fix failed")
        print(error)


emscripten_path = sys.argv[1]
node_root = sys.argv[2]
node_paths = glob(node_root)

# Add the local node bin directory to the path so that
# npm can find it when doing the updating or pruning
os.environ["PATH"] = os.path.join(node_paths[0], "bin") + os.pathsep + os.environ["PATH"]

for path in node_paths:
    prune(os.path.join(path, "lib"))

rewrite_package_json(os.path.join(emscripten_path, "package.json"))
auditfix(emscripten_path)
prune(emscripten_path)
