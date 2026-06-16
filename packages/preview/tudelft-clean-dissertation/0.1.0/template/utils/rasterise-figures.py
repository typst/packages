from pathlib import Path
import glob
import os
import subprocess
import shutil



if __name__ == "__main__":

    ### images

    # # first remove all old rasterised figures, as files may have changed name
    # old_rasterised_imgs = glob.glob('../rasterised-figures/*.png', recursive=True)
    # for file in old_rasterised_imgs: os.remove(file)

    # # now start looking for inkscape source files
    # svg_source_names = glob.glob('../chapters/**/figure-source.svg', recursive=True)
    # svg_source_paths = [Path(p) for p in svg_source_names]

    # # generate rasterised-figures folder if it does not exist yet
    # folder_path = Path('..', "rasterised-figures")
    # folder_path.mkdir(parents=True, exist_ok=True)

    # for path in svg_source_paths:
    #     # build the output file path
    #     output_filename = path.parents[2].stem + "_"+ path.parents[0].stem + ".png"
    #     output = Path("..", "rasterised-figures", output_filename)

    #     # run inkscape export command
    #     cmd = f'inkscape {path.resolve()} --actions="export-filename:{output.resolve()};export-dpi:400;export-background:#ffffff;export-background-opacity:1.0;export-do;file-close"'
    #     print(cmd)
    #     subprocess.run(cmd)

    ### CSV export files

    # first remove all old rasterised figures, as files may have changed name
    old_rasterised_imgs = glob.glob('../rasterised-figures/*.csv', recursive=True)
    for file in old_rasterised_imgs: os.remove(file)

    # now start looking for inkscape source files
    csv_files = glob.glob('../chapters/**/*.csv', recursive=True)
    csv_paths = [Path(p) for p in csv_files]

    for path in csv_paths:
        print(path)
        # build the output file path
        output_filename = path.parents[4].stem + "_"+ path.parents[2].stem + "_" + path.name
        output = Path("..", "rasterised-figures", output_filename)
        shutil.copy(path, output)




