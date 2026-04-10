import subprocess, sys, os, glob, re




def retrieve_unicode_references(webfont_path: str) -> dict:
    unicode_dict : dict = {}
    css_content = open(os.path.join(webfont_path, "tabler-icons.css"),"rt").read()

    matches = re.findall(pattern=r"\.(?:ti-)(.*?)(?::before.*?\"\\)(.*?)(?=\".*?})", flags=re.RegexFlag.S, string=css_content)

    for i,(tag,unicode) in enumerate(matches):
        unicode_dict[tag] = unicode
        print("Icon Progress [{:5} / {:5}]".format(i+1,len(matches)), end='\r')
    print("")
    return unicode_dict




# ---------------------------------------------------------------------------- #
#                          Tabler.io Icons Downloader                          #
# ---------------------------------------------------------------------------- #

# retrieve the latest version
response = subprocess.run(["gh","release","list","--repo","tabler/tabler-icons","-L","1"], check=True, stdout=subprocess.PIPE).stdout.decode().split("\t")
tabler_icons_version = response[2]

print("Version '" + tabler_icons_version + "' retrieved")
print("Downloading release with version '" + tabler_icons_version + "'")

# download said version into a 'tmp' folder
subprocess.run(["gh","release","download","--repo","tabler/tabler-icons","--dir","./tmp",tabler_icons_version])

# ---------------------------------------------------------------------------- #
#                                   Unzipping                                  #
# ---------------------------------------------------------------------------- #
import zipfile

os.chdir("./tmp") # for safety's sake, enter the tmp folder

path = glob.glob("*")[0]
print("Unzipping '" + path + "'")

with zipfile.ZipFile(path + "","r") as zip_ref:
    zip_ref.extractall("./unzipped")


# ---------------------------------------------------------------------------- #
#                         Extracting Unicode References                        #
# ---------------------------------------------------------------------------- #
unicodes = retrieve_unicode_references("./unzipped/webfont/")
os.chdir("..") # go back to script folder

# ------------------------------ Write into file ----------------------------- #
output = open("../_tableau-icons-ref.typ", "wt")

# first write the tabler icons version
tabler_icons_version = tabler_icons_version.replace("v","")

output.write(f"#let tabler-icons-version = \"{tabler_icons_version}\"\n\n")

output.write("#let tabler-icons-unicode = (\n")
for (key, value) in unicodes.items():
    output.write(f"  \"{key}\": \"\\u{{{value}}}\",\n" )
output.write(")")
output.close()


# ---------------------------------------------------------------------------- #
#                                For Doc Header                                #
# ---------------------------------------------------------------------------- #
import random
thumbnail_list = [list(unicodes)[i] for i in (random.sample(range(len(unicodes)), 300))]
thumbnail_file = open("../docs/thumbnail_list.typ", "wt")
thumbnail_file.write("#let thumbnail_list = (\n")
for value in thumbnail_list:
    thumbnail_file.write(f"  \"{value}\",\n" )
thumbnail_file.write(")")
thumbnail_file.close()

# ---------------------------------------------------------------------------- #
#                               Update TOML file                               #
# ---------------------------------------------------------------------------- #
import toml, semver

config = toml.load('../typst.toml')
old_version = semver.Version.parse(config['package']['version'])
tabler_version = semver.Version.parse(tabler_icons_version)

if (str(old_version.minor) == f"{tabler_version.major}{tabler_version.minor}"):
    config['package']['version'] = f"{(old_version.bump_patch())}"
else:
    config['package']['version'] = f"{old_version.major}.{tabler_version.major}{tabler_version.minor}.0"

config['package']['description'] = f"Tabler.io Icons v{tabler_icons_version} for Typst"

f = open("../typst.toml",'w')
toml.dump(config,f)

# ---------------------------------------------------------------------------- #
#                             Update Changelog File                            #
# ---------------------------------------------------------------------------- #
file_changelog = open("../docs/changelog.typ", "r")
current_changelog = file_changelog.read()
file_changelog.close()

new_log = f"""== `v{config['package']['version']}`

- updated Tabler Icons version v{tabler_icons_version}
"""

file_changelog = open("../docs/changelog.typ", "w")
file_changelog.write(f"""{new_log}

{current_changelog}
""")
file_changelog.close()


# ---------------------------------------------------------------------------- #
#                                   Clean Up                                   #
# ---------------------------------------------------------------------------- #
import shutil
print("Deleting temporary folder")
shutil.rmtree('./tmp')

sys.exit(0)