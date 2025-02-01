import glob, re,os

# first create the filled icons list

BASE_PATH = "../../tabler-icons/icons" # path to repository
OUTPUT_PATH = "../icons"

FILLED_PATH = BASE_PATH + "/filled/"
file_list = glob.glob(FILLED_PATH + "/*")

DST_HEADER = "<?xml version=\"1.0\" encoding=\"utf-8\"?><svg xmlns=\"http://www.w3.org/2000/svg\">"
DST_TRAILER = "</svg>"

file_filled = open(OUTPUT_PATH + "/tabler-filled.svg", "wt")
file_filled.write(DST_HEADER)

for i, path in enumerate(file_list):
    print("> Filled [{:5} / {:5}]".format(i+1,len(file_list)), end='\r')
    id = os.path.basename(path).replace(".svg","")
    data = open(path, "rt").read()
    data = re.sub(pattern=r"<!--(.+?)-->",flags=re.RegexFlag.S, string=data, repl="").replace("<svg", "<symbol id=\"" + id + "\"").replace("/svg>", "/symbol>")
    data = re.sub(pattern=r"\n\s*", string=data, repl=" ")
    file_filled.write(data.strip() + "\n")

file_filled.write(DST_TRAILER)
file_filled.close()

# ---------------------------------------------------------------------------- #
#                                   Outlined                                   #
# ---------------------------------------------------------------------------- #
OUTLINE_PATH = BASE_PATH + "/outline/"
file_list = glob.glob(OUTLINE_PATH + "/*")

DST_HEADER = "<?xml version=\"1.0\" encoding=\"utf-8\"?><svg xmlns=\"http://www.w3.org/2000/svg\">"
DST_TRAILER = "</svg>"

file_outline = open(OUTPUT_PATH + "/tabler-outline.svg", "wt")
file_outline.write(DST_HEADER)
print("")
for i, path in enumerate(file_list):
    print("> Outlined [{:5} / {:5}]".format(i+1,len(file_list)), end='\r')
    id = os.path.basename(path).replace(".svg","")
    data = open(path, "rt").read()
    data = re.sub(pattern=r"<!--(.+?)-->",flags=re.RegexFlag.S, string=data, repl="").replace("<svg", "<symbol id=\"" + id + "\"").replace("/svg>", "/symbol>")
    data = re.sub(pattern=r"\n\s*", string=data, repl=" ")
    file_outline.write(data.strip() + "\n")

file_outline.write(DST_TRAILER)
file_outline.close()

print("")
print("DONE")