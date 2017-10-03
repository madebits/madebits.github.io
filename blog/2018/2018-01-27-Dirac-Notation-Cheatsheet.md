#Dirac Notation Cheat Sheet

2018-01-27

<!--- tags: math -->

[Dirac](https://en.wikipedia.org/wiki/Bra%E2%80%93ket_notation) notation quick reference. Assume a $$$\mathbf{C^2}$$$ [Hilbert](https://en.wikipedia.org/wiki/Hilbert_space) space.

##Bra $$$-$$$ Ket

**ket** 

$$$\rvert v \rangle = v_0 \rvert 0 \rangle + v_1 \rvert 1 \rangle \equiv \left[
\begin{array}{cc}  v_0 \cr v_1 \end{array} \right] $$$

**bra**

$$$\langle v \rvert = \overline{v_0} \langle 0 \rvert + \overline{v_1} \langle 1 \rvert \equiv \left[
\begin{array}{cc}  \overline{v_0}, & \overline{v_1} \end{array} \right] $$$

Where:

$$$ \rvert v \rangle^{\dagger} = \langle v \rvert $$$

##Inner Product

$$$\langle v \rvert w \rangle = \overline{v_0}w_0 + \overline{v_1}w_1$$$

$$$ \langle v \rvert w \rangle^{\dagger} = \langle w \rvert v \rangle $$$

$$$ \langle 0 \rvert 0 \rangle = \langle 1 \rvert 1 \rangle = 1 $$$

$$$ \langle 0 \rvert 1 \rangle = \langle 1 \rvert 0 \rangle = 0 $$$

Norm:

$$$ \Vert \rvert v \rangle \Vert^2 = \langle v \rvert v \rangle = v_0^2 + v_1^2$$$

##Coefficients 

$$$ v_0 = \langle 0 \rvert v \rangle $$$

$$$ v_1 = \langle 1 \rvert v \rangle $$$

$$$ \rvert v \rangle = \langle 0 \rvert v \rangle \rvert 0 \rangle + \langle 1 \rvert v \rangle \rvert 1 \rangle $$$

$$$ \rvert v \rangle = \sum_{i=0}^{N-1} \langle e_i \rvert v \rangle \rvert e_i \rangle $$$

Identity operation:

$$$ \sum_{i=0}^{N-1} \rvert e_i \rangle \langle e_i \rvert = \mathbb{1} $$$

##Projections

Outer product:

$$$ \rvert 0 \rangle \langle 0 \rvert = \prod_{\rvert 0 \rangle} = \prod_0 $$$

$$$ \rvert 1 \rangle \langle 1 \rvert = \prod_{\rvert 1 \rangle} = \prod_1 $$$

Projection example:

$$$ \prod_{\rvert 0 \rangle} (\rvert v \rangle) = \prod_0 \rvert v \rangle = \rvert 0 \rangle \langle 0 \rvert \rvert v \rangle = \rvert 0 \rangle \langle 0 \rvert ( v_0 \rvert 0 \rangle + v_1 \rvert 1 \rangle ) = v_0 \rvert 0 \rangle $$$

Matrices:

$$$
A_{2\times2} = \langle 0 \rvert A \rvert 0 \rangle \rvert 0 \rangle \langle 0 \rvert + \langle 0 \rvert A \rvert 1 \rangle \rvert 0 \rangle \langle 1 \rvert + \langle 1 \rvert A \rvert 0 \rangle \rvert 1 \rangle \langle 0 \rvert  + \langle 1 \rvert A \rvert 1 \rangle \rvert 1 \rangle \langle 1 \rvert 
$$$

Where:

$$$ a_{ij} \to \langle i \rvert A \rvert j \rangle $$$

##Linearity

$$$
\langle v \rvert w \rangle = \langle v \rvert (w_0 \rvert \rangle + w_1 \rvert 1 \rangle ) = w_0 \langle v \rvert 0 \rangle + w_1 \langle v \rvert 1 \rangle
$$$

$$$
\langle v \rvert w \rangle = (v_0 \langle 0 \rvert + v_1 \langle 1 \rvert) \rvert w \rangle = v_0 \langle 0 \rvert w \rangle + v_1 \langle 1 \rvert w \rangle
$$$

##Associativity

$$$ \langle v \rvert A \rvert w \rangle = ( \langle v \rvert A ) \rvert w \rangle = \langle v \rvert ( A \rvert w \rangle ) $$$

$$$ A \rvert v \rangle \langle w \rvert =  ( A \rvert v \rangle ) \langle w \rvert = A ( \rvert v \rangle \langle w \rvert ) $$$

##Transpose (Hermitian)

$$$ \langle v \rvert w \rangle^\dagger = \langle w \rvert v \rangle  $$$

$$$ \langle v \rvert A \rvert w \rangle^\dagger = \langle w \rvert A^\dagger \rvert v \rangle  $$$

##Tensor Product

$$$ \rvert v \rangle \otimes \rvert w \rangle = ( v_0 \rvert 0 \rangle + v_1 \rvert 1 \rangle ) \otimes ( w_0 \rvert 0 \rangle + w_1 \rvert 1 \rangle ) = v_0w_0 \rvert 0 \rangle \rvert 0 \rangle + v_0w_1 \rvert 0 \rangle \rvert 1 \rangle + v_1w_0 \rvert 1 \rangle \rvert 0 \rangle + v_1w_1 \rvert 1 \rangle \rvert 1 \rangle = v_0w_0 \rvert 00 \rangle + v_0w_1 \rvert 01 \rangle + v_1w_0 \rvert 10 \rangle + v_1w_1 \rvert 11 \rangle $$$

<ins class='nfooter'><a rel='prev' id='fprev' href='#blog/2018/2018-04-25-OpenVPN-In-Azure.md'>OpenVPN In Azure</a> <a rel='next' id='fnext' href='#blog/2017/2017-10-20-Patching-Node-Express-For-Async-Wait.md'>Patching Node Express For Async Wait</a></ins>
