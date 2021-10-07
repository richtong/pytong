"""Setup Log Python Package."""
# https://packaging.python.org/tutorials/packaging-projects/
# dynamic setup of python package

import setuptools  # type: ignore


with open("README.md", "r", encoding="utf-8") as file:
    long_description = file.read()

setuptools.setup(
    name="pytong",
    version="0.0.1",
    author="Richard C. T. Tong",
    author_email="rich@tongfamily.com",
    long_description=long_description,
    url="https://github.com/richtong/pytong",
    project_urls={
        "Bug Tracker": "https://githubcom/richtong/pytong/issues",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "Licesne :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    python_requires=">3.8",
)
