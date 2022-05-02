#!/usr/bin/env python3

# Made for Catmera by Luis Fariña (luisfl.me)

import argparse
import os
import random
import shutil
import sys

def main(args):
    # Set the parent directory of the specified one as the current directory
    os.chdir(args.directory)
    originalDirectoryAbsolutePath = os.getcwd()
    os.chdir("..")

    # Determine which are the directories whose number of images is greater than
    # or equal to the specified number
    eligibleDirectories = []
    for categoryPath in os.listdir(originalDirectoryAbsolutePath):
        categoryAbsolutePath = os.path.join(originalDirectoryAbsolutePath, categoryPath)
        if os.path.isdir(categoryAbsolutePath) and len(os.listdir(categoryAbsolutePath)) >= args.number:
            eligibleDirectories.append(categoryPath)

    # Create a new directory with the same name as the original one, appending
    # the number of images per category, and also create training and testing
    # data folders inside it
    newDirectoryName = f"{args.directory}_{args.number}"
    os.mkdir(newDirectoryName)
    os.chdir(newDirectoryName)
    for directoryName in ["Training Data", "Testing Data"]:
        os.mkdir(directoryName)

    # For each category, pick 20 % of images for testing and the other 80 %
    # for training, and copy them to their corresponding folders
    for directory in eligibleDirectories:
        categoryAbsolutePath = os.path.join(originalDirectoryAbsolutePath, directory)
        files = random.sample(os.listdir(categoryAbsolutePath), args.number)
        testingFiles = random.sample(files, int(args.number * 0.2))
        trainingFiles = [file for file in files if file not in testingFiles]
        for tuple in [("Training Data", trainingFiles), ("Testing Data", testingFiles)]:
            for file in tuple[1]:
                newFilePath = os.path.join(tuple[0], directory, file)
                os.makedirs(os.path.dirname(newFilePath), exist_ok = True)
                shutil.copyfile(os.path.join(categoryAbsolutePath, file), newFilePath)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog = "generate_data_sources.py",
        description = "An utility for picking N images from each category in a dataset and distributing them between folders for training and testing"
    )
    parser.add_argument(
        "directory",
        type = str,
        help = "directory path in which the folders for the categories are stored"
    )
    parser.add_argument(
        "number",
        type = int,
        help = "number of images to pick from each category"
    )
    main(parser.parse_args())
