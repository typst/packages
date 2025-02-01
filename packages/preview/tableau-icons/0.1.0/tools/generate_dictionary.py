import glob, re,os,base64,sys


os.chdir('../../tabler-icons/icons') # set the working directory to make the script a bit faster

BASE_PATH = "./" # path to repository
OUTPUT_PATH = "../../tableau-icons/icons"

FILLED_PATH = BASE_PATH + "/filled/"
OUTLINE_PATH = BASE_PATH + "/outline/"

DESTINATION_HEADER = "{"
DESTINATION_TRAILER = "}"

print("┌──────────────────────────────────────────────────────────┐\n│   __        __   __     ___  __           __   __        │\n│  /__` \\  / / _` /__`     |  /  \\       | /__` /  \\ |\\ |  │\n│  .__/  \\/  \\__> .__/     |  \\__/    \\__/ .__/ \\__/ | \\|  │\n│                                                          │\n└──────────────────────────────────────────────────────────┘")
print("Converts a list of svg files into a single json file. Key is\nthe icon's file name (without the '.svg') and the value is\nthe contents base64 encoded\n")
# ---------------------------------------------------------------------------- #
#                                 Filled Icons                                 #
# ---------------------------------------------------------------------------- #
file_list = glob.glob(FILLED_PATH + "/*")


dict_filled = {}

# --------------------------- Create the dictionary -------------------------- #
for i, path in enumerate(file_list):
    print(" Filled Icon Progress                       [{:5} / {:5}]".format(i+1,len(file_list)), end='\r')
    id = os.path.basename(path).replace(".svg","")
    data = open(path, "rt").read()
    data = re.sub(pattern=r"<!--(.+?)-->",flags=re.RegexFlag.S, string=data, repl="")
    data = re.sub(pattern=r"\n\s*", string=data, repl=" ")
    dict_filled[id] = str(base64.b64encode(bytes(data.strip() + "\n", "utf-8")),"utf-8")

# ------------------------ Open and write the content ------------------------ #
last_element = list(dict_filled.keys())[-1]

file_filled = open(OUTPUT_PATH + "/tabler-filled.json", "wt")
file_filled.write(DESTINATION_HEADER)
for (k,v) in dict_filled.items():
    file_filled.write("\"" + k + "\"" + ":" + "\"" + v + "\"" + (",\n" if k != last_element else "\n"))
file_filled.write(DESTINATION_TRAILER)

file_filled.close()

# ---------------------------------------------------------------------------- #
#                                Outlined Icons                                #
# ---------------------------------------------------------------------------- #
file_list = glob.glob(OUTLINE_PATH + "/*")
dict_outline = {}

print("")

# --------------------------- Create the dictionary -------------------------- #
for i, path in enumerate(file_list):
    print(" Outlined Icon Progress                     [{:5} / {:5}]".format(i+1,len(file_list)), end='\r')
    id = os.path.basename(path).replace(".svg","")
    data = open(path, "rt").read()
    data = re.sub(pattern=r"<!--(.+?)-->",flags=re.RegexFlag.S, string=data, repl="") # remove comments
    data = re.sub(pattern=r"\n\s*", string=data, repl=" ") # remove newlines to make the structure more compact
    dict_outline[id] = str(base64.b64encode(bytes(data.strip() + "\n", "utf-8")),"utf-8")

# ------------------------ Open and write the content ------------------------ #
last_element = list(dict_outline.keys())[-1]

file_outline = open(OUTPUT_PATH + "/tabler-outline.json", "wt")
file_outline.write(DESTINATION_HEADER)
for (k,v) in dict_outline.items():
    file_outline.write("\"" + k + "\"" + ":" + "\"" + v + "\"" + (",\n" if k != last_element else "\n"))
file_outline.write(DESTINATION_TRAILER)
file_outline.close()

print("\nDONE")
sys.exit(0)