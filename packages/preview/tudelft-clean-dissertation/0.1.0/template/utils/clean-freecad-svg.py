from lxml import etree
import sys
from pathlib import Path


def clean_freecad_SVG(input_path):
    """
    Opens an SVG file created by freeCAD's techdraw SVG export, and 
    removes edges, keeping only the face objects. Removes groups that
    serve no function. Sets stroke to black and fill to gray. Saves the output
    file with form 'cleaned_{input}.svg', which can be dragged and dropped into
    inkscape as editable SVG.

    In the freeCAD techdraw export, make sure to avoid hatching faces, and use
    a blank page template in techdraw.

    Args:
        input_file: Path to input SVG file
        output_file: Path to output SVG file
    """

    print()
    if input_path.stem.startswith("schematic"): 
        print(f"Ignoring {input_path}, as it starts with 'schematic' ...")
        return

    # Parse the SVG file
    tree = etree.parse(input_path)
    root = tree.getroot()
    
    # Define SVG namespace
    nsmap = root.nsmap
    svg_ns = nsmap.get(None, 'http://www.w3.org/2000/svg')
    if 'freecad' not in nsmap:
        #print(f"Skipping {input_file}: No xmlns:freecad attribute found")
        #print("This script only processes FreeCAD SVG files")
        return
    if 'processed-for-inkscape' in root.attrib:  # check if we processed this file before
        return
    
    # add an attribute e to the root to show that this document has been processed
    root.set("processed-for-inkscape", "true")

    print(f"\nCleaning up the SVG of {input_path}")

    
    # Create the a group element with the name of the file
    drawing_group = etree.Element(
        f'{{{svg_ns}}}g',
        attrib={'id': input_path.stem}  
    )
    
    # Find all path elements with non-scaling stroke (these are face objects)
    paths_to_keep = []
    
    # Recursively find all elements in the document
    for elem in root.iter():
        if elem.tag == f'{{{svg_ns}}}path' or elem.tag == 'path':
            vector_effect_attr = elem.get('vector-effect')
            if vector_effect_attr == "non-scaling-stroke":
                # remove the non-scaling-stroke
                del elem.attrib['vector-effect']
                # apply a stroke and fille so that it previews nicely in inkscape
                elem.set('style', 'fill:#f2f2f2;stroke:#000000;stroke-width:2;stroke-dasharray:none')
                # Store the path element
                paths_to_keep.append(elem)


    if len(paths_to_keep) == 0:
        raise ValueError('No elements found in the source drawing!')

    
    # Remove all children from root
    for child in list(root):
        root.remove(child)
    
    # Add paths to the drawing group
    for path in paths_to_keep:
        drawing_group.append(path)
    
    # Add the drawing group to root
    root.append(drawing_group)

    
    # Write the modified SVG to output file
    output_file = input_path.with_stem("cleaned_" + input_path.stem)
    tree.write(output_file, pretty_print=True, xml_declaration=True, encoding='utf-8')
    print(f"Successfully processed SVG. Output saved to {"cleaned_" + input_path.stem + ".svg"}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python clean_freecad_svg.py <input_svg_file>")
        sys.exit(1)
        
    # Example usage
    input_svg = Path(sys.argv[1])
    
    try:
        clean_freecad_SVG(input_svg)
    except FileNotFoundError:
        print(f"Error: Could not find {input_svg}")
    except Exception as e:
        print(f"Error processing SVG: {e}")