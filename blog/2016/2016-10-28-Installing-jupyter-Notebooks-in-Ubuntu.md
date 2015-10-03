#Installing Jupyter Notebooks in Ubuntu

<!--- tags: linux python -->

2016-10-28

In Ubuntu 16.04 both Python 2 an 3 are available via the repositories. Assuming you have installed Python, then the following will install `ipython`:

```bash
sudo apt install ipython ipython3
```

To install and update `pip` use:

```bash
sudo apt install python-pip python-pip3
``` 

By default `pip` will point to `pip2`:

```bash
$ whereis pip
pip: /usr/bin/pip /usr/local/bin/pip2.7 /usr/local/bin/pip
```

To get latest versions use:

```bash
sudo -H pip install --upgrade pip
sudo -H pip3 install --upgrade pip
pip install ipython --upgrade
pip3 install ipython --upgrade
```

While Python notebook is deprecated the package is still needed on Ubuntu:

```bash
sudo apt install ipython-notebook ipython3-notebook
```

After that install [Jupyter](http://jupyter.org/):

```bash
sudo -H pip install jupyter
sudo -H pip3 install jupyter
```

To make [both](http://stackoverflow.com/questions/30492623/using-both-python-2-x-and-python-3-x-in-ipython-notebook) python 2 and 3 available in `jupyter` use:

```bash
sudo ipython kernel install
sudo ipython3 kernel install
```

Now you can start `jupyter` using any of the following:

```bash
jupyter notebook
ipython notebook
ipython3 notebook
```

By default, http://localhost:8888/ is used for notebooks and can be open in browser.

If you want to use also the [R kernel](https://www.r-bloggers.com/r-kernel-in-jupyter-notebook-3/):

```bash
sudo apt install libzmq3-dev python-zmq
```

Then within R (or RStudio) run:

```r
install.packages(c('rzmq','repr','IRkernel','IRdisplay'),
                  repos = c('http://irkernel.github.io/',     
                  getOption('repos')),
                  type = 'source')
IRkernel::installspec()
```

This will download, build, and install the Jupyter R kernel.

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2016/2016-10-29-Python-Conference-Munich.md'>Python Conference Munich</a> <a rel='next' id='fnext' href='#blog/2016/2016-10-02-xrandr-Panning-with-no-Tracking.md'>xrandr Panning with no Tracking</a></ins>
