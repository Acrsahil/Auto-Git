path = ""
import os


def getpath():

    maindir = os.path.dirname(os.path.abspath(__file__))
    path = input()
    with open(f"{maindir}/path.txt", "w") as file:
        file.write(path)

def prints():
    return path


if __name__ == "__main__":
    getpath()
else:
    prints()
