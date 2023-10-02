import json

file = open("scan_mine_23/inspect_data.json", "r")
data = json.load(file)

tags = {}

for block in data:
    print(block["name"])
    for tag, value in block["tags"].items():
        if tag not in tags:
            tags[tag] = 1
        else:
            tags[tag] += 1

print("\n\n\n", len(data))
for tag, count in tags.items():
    if count > 3:
        print(f"{tag}: {count}:")
        for block in data:
            if tag not in block["tags"]:
                print(f"\t!!! {block['name']}")




