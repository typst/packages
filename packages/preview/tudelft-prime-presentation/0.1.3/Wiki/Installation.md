# Installation

At the time of this writing, we used Typst version 0.13.1. In addition, this template currently uses the *Lato* font for text, and the *Lete Sans Math* for math. If your system does not have these fonts installed, please install them by clicking at the corresponding font files. The *Lato* font can be downloaded from [this link](https://fonts.google.com/specimen/Lato), and the *Lete Sans Math* from [this link](https://github.com/abccsss/LeteSansMath).

One should be able to use the template once it is available in the [Typst Universe](https://typst.app/universe/).

## Manual Installation as a local package

The template can be installed in our local machine. We recommend downloading one of the released versions (e.g. 0.1.2) and 
extract it.

Although the instruction for **manually** installing local packages can be found in the [Typst's offcial repository](https://github.com/typst/packages?tab=readme-ov-file#local-packages), we provide specific instructions to install our package.


### Installation on Windows

1. Open a PowerShell
2. Create the directory for the package

    ```powershell
    cd $home
    mkdir .\AppData\Roaming\typst\packages\local\tudelft-PRIME-presentation\0.1.2
    cd .\AppData\Roaming\typst\packages\local\tudelft-PRIME-presentation\0.1.2
    explorer .
    ```

    The command `explorer .` open the directory where to copy the files.

3. Copy the contents of the zip file into the previous directory.

### Installation on MacOS

1. Open a terminal
2. Create the directory for the package:


    ```bash
    mkdir -p "~/Library/Application Support/typst/packages/local/tudelft-PRIME-presentation/0.1.2" 
    cd "~/Library/Application Support/typst/packages/local/tudelft-PRIME-presentation/0.1.2" 
    open .
    ```
    
    The command `open .` opens the directory where to copy the files.

3. Copy the contents of the zip file into the previous directory.


### Installation on Linux (tested on Debian aarch64)

1. Open a terminal
2. Create the directory for the package:

    ```bash
    mkdir -p "~/.local/share/typst/packages/local/tudelft-PRIME-presentation/0.1.2"
    cd "~/.local/share/typst/packages/local/tudelft-PRIME-presentation/0.1.2"
    xdg-open .
    ```

    the command `xdg-open .` opens the directory where to copy the files.

3. Copy the contents of the zip file into the previous directory.

## Using a Package Manager

The package manager we chose for installing the template is called [typship](https://github.com/sjfhsjfh/typship/tree/v0.4.1).
The installation depends on your operating system.

### Installing Typshyp

#### Installation of Typship on MacOS and Linux

The easiest way to install the package manager is through Rust's `cargo`. Install the latest version of Rust from the [official website](https://www.rust-lang.org). Then install the typst package manager `typship` with

```bash
cargo install typship
```

If you prefer, on MacOS you can install it with `brew`, and on Linux you can download the prebuild binary files using a shell script. (follow the instructions on the [official website](https://github.com/sjfhsjfh/typship/releases)), 

#### Installation of Typship on Windows

Go to the the [realease page](https://github.com/sjfhsjfh/typship/releases/) of typship on GitHub. Download the zip file named `typship-x86_64-pc-windows-msvc.zip`. Once extracted, you will find the file `typship.exe`. 

1. Copy the file into `C:\Users\{your_user}\Downloads`
2. Open a `PowerShell`
3. Copy and paste the following code into the PowerShell, and run it:

    ```powershell
    cd $home
    New-Item -Path . -Name "Software" -ItemType "Directory" -Force
    Copy-Item -Path .\Downloads\typship.exe -Destination "$home\Software"
    $currentPath = (Get-ItemProperty "HKCU:Environment").PATH
    $newPath = -join("$currentPath","$home\Software",";")
    Remove-ItemProperty -Path "HKCU:Environment" -Name "Path" -Force
    New-ItemProperty -Path "HKCU:Environment" -PropertyType 'ExpandString' -Name 'Path' -Value "$newPath"
    ```

### Installing the Template

#### Windows

1. Navigate using the file explorer to the extracted zip file containing the template
2. Rigth click on the folder's white space
3. Select `Open in Terminal` (a PowerShell will open at the directory containing the template)
4. Run the following command:

    ```powershell
    typship install local
    ```
5. Template is really to use

#### MacOS and Linux

1. Open a terminal
2. Navigate to the directory where the template has been extracted
3. Run the following command

    ```bash
    typship install local
    ```

