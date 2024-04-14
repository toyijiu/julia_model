import pandas as pd
from pathlib import Path
import hashlib

def hash_id(worker_id):
    return 'w' + hashlib.md5(worker_id.encode()).hexdigest()[:7]

for pth in Path('data').rglob("participants.pkl"):
    d = pd.read_pickle(pth)
    changed = False
    for k in ['worker_id', 'participant_id']:
        if k in d:
            print('redacting', pth)
            d[k] = 'REDACTED'
            changed = True
    if changed:
        d.to_pickle(pth)

d = pd.read_csv('analysis/experiment4_demographics.csv')
d['wid'] = d.participant_id.apply(hash_id)
d.participant_id = 'REDACTED'
d.to_csv('analysis/experiment4_demographics.csv')
