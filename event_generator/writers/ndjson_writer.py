import json 
from dataclasses import asdict 
from pathlib import Path



def write_ndjson(filename: str,objects):
    """
    Writes a collection of dataClass objecst into NDJSON FORMAT
    """
    Path("data").mkdir(exist_ok=True)
    filepath=Path('data')/filename 
    # ==========================
    # Debug
    # ==========================
    print("Working Directory:", Path.cwd())
    print("Writing to:", filepath.resolve())

    with open(filepath,"w",encoding="utf-8") as file:

        for obj in objects:
            print(obj)   # <-- temporary debugging
            json.dump(asdict(obj),file,default=str )
            file.write("\n")
    print(f"created {filepath}")