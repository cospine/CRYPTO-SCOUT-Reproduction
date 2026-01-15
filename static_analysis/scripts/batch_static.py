import os
import json
import subprocess

SAMPLES_DIR = "/samples"     
OUTPUT_FILE = "/samples/results.jsonl"

def analyze_file(filepath):
    filename = os.path.basename(filepath)
    env = os.environ.copy()
    env["OPTION"] = "p"
    env["BYTECODE_DIR"] = SAMPLES_DIR
    env["BYTECODE_FILE_NAME"] = filename

    # Python3.6 不支持 text=True, 必须用 universal_newlines=True
    result = subprocess.run(
        ["sh", "run.sh"],
        cwd="/crypto_scout",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True,
        env=env
    )

    lines = result.stdout.strip().split("\n")
    for line in reversed(lines):
        line = line.strip()
        if line.startswith("{") and line.endswith("}"):
            try:
                data = json.loads(line)
                data["filename"] = filename 
                return data
            except:
                pass
    return None


def main():
    results = []
    files = sorted(os.listdir(SAMPLES_DIR))
    total = len(files)
    print("Found {} files.".format(total))

    with open(OUTPUT_FILE, "w") as fout:
        for i, fname in enumerate(files):
            fpath = os.path.join(SAMPLES_DIR, fname)

            if not os.path.isfile(fpath):
                continue

            print("[{}/{}] Processing {} ...".format(i+1, total, fname))
            res = analyze_file(fpath)

            if res is None:
                print("  -> ERROR: No JSON output")
                continue

            fout.write(json.dumps(res) + "\n")
            fout.flush()

    print("\nAll done. Results saved to {}".format(OUTPUT_FILE))


if __name__ == "__main__":
    main()
