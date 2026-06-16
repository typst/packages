import re
import pathlib
import warnings
from pprint import pprint

def parse_bib_titles(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        bibcontent = f.read()

    # split by entries first
    entries = bibcontent.split('@')[1:]  # Skip empty first element
    
    titles = []
   
    
    for entry in entries:
        # now search for the title entry (usually the first, but I am not sure
        # if I formatted consistently)
        titles.append(find_title(entry))

    return titles


def find_title(entry):
    IDpattern = r'{(.*?),'
    titlepattern = re.escape("=") + r'(.*?)' + re.escape("},")
    
    lines = entry.strip().split('\n')
    #print(lines[0])

    citation_ID = re.findall(IDpattern, lines[0])[0]  # get the @<citation_ID>, 
    for line in lines:
        line = line.strip()
        if line.lower().startswith('title'):
            # extract title from 'title={<target>},'
            match = re.search(titlepattern, line, re.DOTALL)

            if match:
                title = match.group(1).replace("{", "").replace("}", "").strip()
                #print(title)
                return (citation_ID, title)
            else:
                print(match)
                raise ValueError

    raise ValueError


def find_citations(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    pattern = r'#cite\(<(.*?)>\)'
    matches = re.findall(pattern, content)
    return set(matches)


def check_duplicate_references(citations):
    print("\n>> checking for duplicate entries in .bib files...\n")
    # find duplicate titles
    seen = set()
    duplicates = []
    # Iterate over each element in the list
    for (citation_ID, title) in citations:
        if title in seen:
            duplicates.append(title)
        else:
            seen.add(title)

    if duplicates:
        print("The following references occur more than once in the repository")
        pprint(duplicates)
    else:
        print("No duplicate bibtex entries found!")


def check_unused_references(citations, cited):
    print("\n>> checking for unused entries in .bib files...\n")
    # extract the citation_IDs into a set
    bibtex_IDs = set(map(lambda x: x[0], citations))

    # check for unused references (i.e. .bib entries that are not referenced)
    unused_references = bibtex_IDs.difference(cited)
    if unused_references:
        print(f"The following references are present in .bib files but not referenced in any typst file:") 
        pprint(unused_references)
    else:
        print("No unused references!")
    
    # In theory we could have a #cite(<A>) with no A in the .bib files.
    # The typst compiler will not let that happen, so this should always be
    # an empty set. The exception is if there is a #cite(<A>) statement in
    # a comment.
    orphaned_citations = cited.difference(bibtex_IDs)
    if orphaned_citations:
        warnings.warn(f"Found a citing statement in a .typ file that has no .bib equivalent. Please investigate.")
            
if __name__ == "__main__":
    # find .bib files
    bib_files = list(pathlib.Path("../").rglob('*.bib'))

    # Example: parse all bib files"
    citations=[]
    for file in bib_files:
        citations = citations + parse_bib_titles(file)

    # find citations in .typ files
    typst_files = list(pathlib.Path("../").rglob('*.typ'))
    cited = set()
    for file in typst_files:
        cited = cited | find_citations(file)

    # check for duplicate references (based on title, as not all have DOI listed)
    check_duplicate_references(citations)

    # check for unused references (i.e. in .bib file but not references in any .typ file)
    check_unused_references(citations, cited)
    

