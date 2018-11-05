import argparse
import requests
from mylib import foo

def main():
  parser = argparse.ArgumentParser(description="test args")
  parser.add_argument("bar", type=str)
  args = parser.parse_args()
  with open("/tmp/py3project/testfile.out", "w") as f:
    f.write(foo(args.bar))

if __name__ == '__main__':
  main()
