#Clustering People

2015-01-15

<!--- tags: ml python -->

I looked at the problem of having a list of people names along with other data that contains possible mistakes and wishing to make the list unique by finding the same person despite of slight text errors. For example, in the fake sample data list below, we have three unique people and a total of nine records:

```
Name,Surname,Email,Address
Markus,Smith,v@e.com,bdd2
Jane,Tarzan,jane@google.com,some street 1
Williams,Johnson,v@e.com,add1
Mark,Smith,m1@e.com,bd
Dr. William,Johnson,v1@e.com,add
Marku,Smit,m@e.com,bdd2
Will,John,v1@e.com,add1
Jane,Tarzan,jane@ymail.com,some street 1
J,Tarzan,jane@google.com,street
```

I put up some quick Python code to cluster the people based on such data:

```python
from __future__ import print_function, division
import numpy as np
import pandas as pd
import jellyfish
from scipy.cluster.vq import *
import math

data = pd.read_csv('data.csv', header=0)
#data.rename(columns={'Name':'Firstname'}, inplace=True)
print(data)

def distance(str1, str2):
    return jellyfish.jaro_winkler(str1, str2)
    
    
def row_distance(dataDistance, rowIndex, nextRowIndex, row, nextRow, cols):
    dataDistance[nextRowIndex][rowIndex] = 0
    
    for c in range(0, cols):
        d = distance(row[c], nextRow[c])
        dataDistance[nextRowIndex][rowIndex] += d; # linear sum, weight 1
        
    dataDistance[nextRowIndex][rowIndex] = dataDistance[nextRowIndex][rowIndex] / cols
    dataDistance[rowIndex][nextRowIndex] = dataDistance[nextRowIndex][rowIndex]  
         
         
def calc_distances(data):
    rows, cols = data.shape
    dataDistance = pd.DataFrame(np.eye(rows, dtype=np.float32))
    
    for rowIndex, row in data.iterrows():
        #dataDistance[rowIndex][rowIndex] = 1
        for nextRowIndex in range(rowIndex + 1, rows):
            nextRow = data.iloc[nextRowIndex]
            row_distance(dataDistance, rowIndex, nextRowIndex, row, nextRow, cols)

    return dataDistance    


def calc_distances2(data):
    rows, cols = data.shape
    dataDistance = pd.DataFrame(np.eye(rows, dtype=np.float32))
    
    def calc_row(row):
        rowIndex = row.name
        nextRows = data.ix[rowIndex:]
        #dataDistance[rowIndex][rowIndex] = 1
        
        def cal_row_inner(nextRow):
            nextRowIndex = nextRow.name
            row_distance(dataDistance, rowIndex, nextRowIndex, row, nextRow, cols)
                
        nextRows.apply(cal_row_inner, axis=1)
    
    
    data.apply(calc_row, axis=1)    
    return dataDistance  


dataDistance = calc_distances(data).as_matrix()
#dataDistance = calc_distances2(data).as_matrix()
#print(dataDistance)

guess = math.ceil(math.sqrt(data.shape[0] / 2))
centroids, _ = kmeans(dataDistance, guess)
idx, _ = vq(dataDistance,centroids)
#print(idx)
index = pd.Series(idx)
print("\nResult");
for group in np.sort(np.unique(idx)):
    print("P", group)
    print(data.ix[index[index == group].index])
```

It outputs the following:

```
          Name  Surname            Email        Address
0       Markus    Smith          v@e.com           bdd2
1         Jane   Tarzan  jane@google.com  some street 1
2     Williams  Johnson          v@e.com           add1
3         Mark    Smith         m1@e.com             bd
4  Dr. William  Johnson         v1@e.com            add
5        Marku     Smit          m@e.com           bdd2
6         Will     John         v1@e.com           add1
7         Jane   Tarzan   jane@ymail.com  some street 1
8            J   Tarzan  jane@google.com         street

[9 rows x 4 columns]

Result
P 0
     Name Surname     Email Address
0  Markus   Smith   v@e.com    bdd2
3    Mark   Smith  m1@e.com      bd
5   Marku    Smit   m@e.com    bdd2

[3 rows x 4 columns]
P 1
   Name Surname            Email        Address
1  Jane  Tarzan  jane@google.com  some street 1
7  Jane  Tarzan   jane@ymail.com  some street 1
8     J  Tarzan  jane@google.com         street

[3 rows x 4 columns]
P 2
          Name  Surname     Email Address
2     Williams  Johnson   v@e.com    add1
4  Dr. William  Johnson  v1@e.com     add
6         Will     John  v1@e.com    add1

[3 rows x 4 columns]
```

The code works, but may be I have to see how to improve it further. The complexity in both time and space is `O(n^2)`, which is to be expected as I have to compare each pair for the distance. For the data I have, both `calc_distances` and `calc_distances2` are more or less same fast. Distance data is a triangular matrix with identity diagonal, but I fill all of it as it is used as input to `kmeans` function. `guess` is better given as input (or recalculated based on distortion), same process can be run iteratively on each result group. I use same weight for all parts, but it is easy to change this code to use a different weight for each data column.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2015/2015-01-29-Arch-Linux-with-LXDE.md'>Arch Linux with LXDE</a> <a rel='next' id='fnext' href='#blog/2015/2015-01-13-Mac-OS-on-VMWare-Player.md'>Mac OS on VMWare Player</a></ins>
