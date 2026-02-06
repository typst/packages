import re,os,sys


os.chdir('../../tabler-icons-3.29.0/webfont') # set the working directory to make the script a bit faster

BASE_PATH = "./" # path to repository
OUTPUT_PATH = "../../tableau-icons"

print("┌──────────────────────────────────────────────────────────┐\n│   __        __   __     ___  __           __   __        │\n│  /__` \\  / / _` /__`     |  /  \\       | /__` /  \\ |\\ |  │\n│  .__/  \\/  \\__> .__/     |  \\__/    \\__/ .__/ \\__/ | \\|  │\n│                                                          │\n└──────────────────────────────────────────────────────────┘")
print("Converts a list of svg files into a single unicode typst file\n")

# ------------------------------- Prepare Files ------------------------------ #
css_content = open("./tabler-icons.css","rt").read()
output = open(OUTPUT_PATH + "/_tableau-icons-ref.typ", "wt")
output.write("#let tabler-icons-unicode = (\n")

taglist = open(OUTPUT_PATH + "/docs/tag-list.txt", "wt")

# ----------------------------------- Parse ---------------------------------- #
matches = re.findall(pattern=r"\.(?:ti-)(.*?)(?::before.*?\"\\)(.*?)(?=\".*?})", flags=re.RegexFlag.S, string=css_content)

for i,(tag,unicode) in enumerate(matches):
    print(" Filled Icon Progress                       [{:5} / {:5}]".format(i+1,len(matches)), end='\r')
    output.write(f"  \"{tag}\": \"\\u{{{unicode}}}\",\n" )
    taglist.write(f"\"{tag}\",\n")
#    print(" Filled Icon Progress                       [{:5} / {:5}]".format(i+1,len(file_list)), end='\r')
output.write(")")
output.close()
taglist.close()

dict_filled = {}

print("\nDONE")
sys.exit(0)