import os
import shutil

def organize_files():
    downloads_folder = os.path.expanduser("~/Downloads")
    organized_folder = os.path.join(downloads_folder, "Organized")

    if not os.path.exists(organized_folder):
        os.makedirs(organized_folder)

    for filename in os.listdir(downloads_folder):
        if filename.endswith('.pdf'):
            shutil.move(os.path.join(downloads_folder, filename), os.path.join(organized_folder, 'PDFs', filename))
        elif filename.endswith('.jpg') or filename.endswith('.png'):
            shutil.move(os.path.join(downloads_folder, filename), os.path.join(organized_folder, 'Images', filename))
        elif filename.endswith('.txt'):
            shutil.move(os.path.join(downloads_folder, filename), os.path.join(organized_folder, 'TextFiles', filename))

    print("Files organized successfully!")

if __name__ == "__main__":
    organize_files()