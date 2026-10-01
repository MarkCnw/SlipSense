import os
import glob
import re

swift_files = []
for root, dirs, files in os.walk('./SlipSense'):
    for file in files:
        if file.endswith('.swift'):
            swift_files.append(os.path.join(root, file))

results = []
for file in swift_files:
    basename = os.path.basename(file).replace('.swift', '')
    # Skip App file or ContentView
    if 'App' in basename or basename == 'ContentView':
        continue
    
    # Check if basename is used in any OTHER file
    used = False
    for other_file in swift_files:
        if other_file == file:
            continue
        with open(other_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # simple regex to find the basename as a whole word
            if re.search(r'\b' + basename + r'\b', content):
                used = True
                break
    
    if not used:
        results.append(basename + " (from " + file + ")")

print("Potentially Unused Files (by file name/type name reference):")
for r in results:
    print(r)
