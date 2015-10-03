#Plustek OpticSlim 2400 Scanner in Lubuntu

2013-07-27 

<!--- tags: linux -->

To install my Plustek OpticSlim 2400 Scanner in Lubuntu, I installed:
```
sudo apt-get install sane xsane
```

Then I copied the scanner [firmware](https://plus.google.com/102311152856914456866/posts/6LFXw8RBKDZ) file [cis3R5B1.fw](blog/images/cis3R5B1.fw) as root under `/usr/share/sane/gt68xx`. `gt68xx` folder has to be created.

After this both Simple Scan and `xsane` tools work.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2013/2013-08-02-CSharp-Obtaining-Method-Parameter-Names.md'>CSharp Obtaining Method Parameter Names</a> <a rel='next' id='fnext' href='#blog/2013/2013-07-26-Samsung-ML-1915-Printer-on-Lubuntu.md'>Samsung ML 1915 Printer on Lubuntu</a></ins>
