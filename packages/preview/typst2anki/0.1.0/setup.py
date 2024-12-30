from setuptools import setup, find_packages

setup(
    name="typst2anki",
    version="0.1.1",
    author="sgomezsal",
    author_email="sgomezsalazar7@gmail.com",
    description="Convert Typst files into Anki cards automatically.",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/sgomezsal/typst2anki",
    packages=find_packages(),
    include_package_data=True,
    install_requires=[
        "requests",
    ],
    entry_points={
        "console_scripts": [
            "typst2anki=typst2anki.main:main",
        ],
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
)
