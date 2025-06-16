import json, os.path, sys, urllib.request

data = json.load(sys.stdin)

for item in data:
    url = item['url']
    path = item['path']
    if not os.path.isfile(path):
        print(f"{path}: downloading {url}")
        os.makedirs(os.path.dirname(path), exist_ok=True)
        urllib.request.urlretrieve(url, path)
    else:
        print(f"{path}: skipping")
