#User-Driven Password Policy

2017-03-22

<!--- tags: architecture -->

A password is a user real world key equivalent to control access to a digital resource. Password has therefore same value to user as the protected digital resource. As with any object of value, the value is the eyes of the beholder and it is not an absolute quantity.

When asking user for a password for protecting a digital resource, the first question to ask the user should be: how much value does this resource has for you. We should try to quantify the value in some easy scale to fit all users and map that scale to a recommended password length. A minimum strength could be needed to protected the service itself, but the service should preferably not rely on that.

$$recommendedMinimumPasswordLength = function(valueForTheUser)$$

Sometimes, the value to password length mapping is easy to derived from the domain. For example, for encryption software, one can derive the value it has for the user based on the encryption algorithm key length user selected. When nothing else is available, we can show a simple scale ranging from not important, to very important.

```
How important is preventing others to access your data:
[ ] Not so important
[x] Somehow important
[ ] Very important
```

Once user has provided feedback on the value of the digital resource, we can compute a recommended minimal password length and show a range scale with three zones: red, orange / yellow, green where the green zone corresponds to the full password length and red to the shortest. As user enters the password, the scale is updated with correct indication of relative length.

![](blog/images/pass.png)

Length is the most important factor of password quality, but not the only one. Additional feedback help to the user can be the anti-entropy of the password string as the user types it in a similar red, orange, green scale, where green corresponds to the maximum anti-entropy.

In this model, the user has the control to decide what kind of password strength is needed and gets feedback on the quality of the actual password used.

<ins class='nfooter'><a rel='next' id='fnext' href='#blog/2017/2017-03-08-Checkpoint-Security-On-Ubuntu.md'>Checkpoint Security On Ubuntu</a></ins>
