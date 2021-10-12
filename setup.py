import setuptools  # type: ignore

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="pytong",
    version="0.0.9",
    author="Richard Tong",
    author_email="rich@tongfamily.com",
    description="Rich Tong's Fine Utilities",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/richtong/pytong",
    project_urls={
        "Bug Tracker": "https://github.com/richtong/pytong/issues",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    python_requires=">=3.6",
)
