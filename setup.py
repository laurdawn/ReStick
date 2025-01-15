from setuptools import setup

APP = ['main.py']
DATA_FILES = []
OPTIONS = {
    'argv_emulation': True,
    'plist': {
        'CFBundleName': 'ReStick',
        'CFBundleDisplayName': 'ReStick',
        'CFBundleIdentifier': 'com.laurdawn.ReStick',
        'CFBundleVersion': '0.0.1',
        'CFBundleShortVersionString': '1.0',
        'NSHumanReadableCopyright': 'Copyright © 2025, laurdawn',
        'LSUIElement': True,
    },
    'packages': ['AppKit', 'objc'],
}

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)
