#Exploring Digital Camera Specifications

2013-03-02

<!--- tags: photo -->

*A summary of major photography terminology used in digital cameras.*

<div id='toc'></div>

##Focal Length of Lens

Focal length `f` is the distance between the lens center and the singularity point (focus point) where it focuses the light. Focal length of a lens is usually measured in millimeters (mm) [1].

For a distant object put at distance $$$S_1$$$ (object distance) before a thin convex lens that is imaged (projected) upside-down at a distance $$$S_2$$$ (image distance) after the lens, the following formula can be used to connect the three distances (we assume both $$$S_1$$$ and $$$S_2$$$ are positive numbers):

$$
\frac{1}{S_1} + \frac{1}{S_2} = \frac{1}{f}
$$

This formula is an approximate of thick lens formula (that considers the lens width) [2]. In a camera, usually $$$S_2$$$ is modified to achieve zoom. The shorter the $$$f$$$ the more optical power has the lens. The minimal focal length of specified for a lens is an indication of its potential optical power. The segment of minimal and maximal focal length a lens system supports, is the **focal range**.

##35mm Film Reference

Kodak analog camera film 135 was **35mm** wide with film frames sized 24mm x 36mm, and a diagonal of 43.3mm (the aspect ratio is 2:3). The 35mm film frame size is used as reference to compare lens parameters.

Digital cameras have usually image sensors with diagonals smaller than 43.3mm, so their lens characteristics cannot be directly compared. They are usually mapped to **35mm equivalents**.

Crop factor (CF) (know also as *focal length multiplier* (FLM)) is the ratio between 35mm diagonal and camera's actual image sensor diagonal $$$d$$$:

$$
CF = \frac{43.3mm}{d}
$$

My camera's documentation states that its lens have a focal range of 4.5mm to 108mm mapping to 35mm equivalent 25mm - 600mm. Based on these data, the image sensor diagonal for my camera is 7.794mm or around 7.8mm and $$$CF=5.55555555556$$$.

A small image sensor is important for a super-zoom digital camera in order to keep the length of lens moderate.

##Optical Zoom

Optical zoom of the lens system is calculated by the following formula [5], where $$$f$$$ is the focal length:

$$
OpticalZoom = \frac{max(f)}{min(f)}
$$

For example, for my camera lens with focal length range 25mm - 600mm (35mm equivalent), the optical zoom is 24.

Optical zoom is a property of the lens. It is a relative measurement. When the lens is attached to a camera 1x optical zoom is when the minimum focal length 25mm is used, and 24x is when the maximal focal length 600mm is used.

##Angle (Field) of View

A camera has an angle of view (called also **field of view** `FOV`) that defines the extent of a scene that can be captured by a camera system using its lens [6]. Usually the lens have a wider view angle, but to avoid edges distortion only a central part of it may be mapped to the image sensor (angle of coverage). The camera angle of view is a function of its lens focal length $$$f$$$ and of the camera sensor size $$$d$$$ where the image is projected. $$$d$$$ is usually the diagonal of the camera image sensor.

$$FOV_{radian} = 2 arctan(\frac{d}{2 f})$$

$$FOV\_{degrees} = \frac{180}{ \pi } FOV\_{radian}, \pi = 3.14159$$


For my camera, the `d` is approximately 7.8mm, so the angle of view `FOV` varies from 81.8 degrees to 4.1 degrees (for the 25mm - 600mm (35mm equivalent) range). The more zoom in, the smaller is the angle of view, which makes sense (focal length (f) and field of view (FOV) of a lens are inversely proportional [1]). The mapping of focal range to angle of view range is not linear.

Human eye field of view with both eyes is around 130 degrees [8], but we can focus only on a much smaller range.

Angle of view range describes a camera same good as its 35mm equivalent focal length range, because both take the size of the camera image sensor into account.

FOV can be used to roughly classify the lens. Wide-angle (W) lens are those with focal length <= 35mm. Telephoto (T) lens have focal length >=85mm. The in-between ones are the middle-range lens. Sometimes the middle-range 50mm lens are referred as *normal lens*.

##Camera Image Sensor Size

From the 35mm focal range equivalent one can find the actual camera sensor size. As I found above, using the `CF`, the diagonal of my camera's image sensor was around 7.8mm.

Documentation of most cameras reports the image sensor size in some non-standardized *"inch"* system [11]. Non-standardized here means that same reported *"inch"* size can mean slightly a different actual size in different cameras. One inch is 25.4 mm (unlike Amazon camera prices, this value does not change depending when you look for it :).

For my camera, its documentation reports an image sensor diagonal size of 1/2.3". According to [11] this reported size is usually 1/3 smaller than the actual size. If we do the math, then $$$\frac{2}{3} \* \frac{1}{2.3} \* 25.4 = 7.4mm$$$. This is approximately same as the value 7.8mm using the reported 35mm equivalent above, and approximately same as the reference size of 7.66mm of reported in [11].

35mm film reference camera has a reference diagonal of 43.3mm = 1.7 inch (CF = 1).

Image sensor size means nothing per se. The Kodak 135 reference film had an image sensor with 43.3mm diagonal, but the sensor itself was analogue film with chemicals exposed to light. What also matters is the technology used for the image sensor chip, sensor light sensitivity, sensor digital signal sampling capabilities, signal to noise ratio, color mapping, etc.

Only if we compare same technology for same chip family, then a bigger sensor size is usually better (thought the luminance of light is bigger on a smaller sensor, than on a bigger one). For same sensor chip less sampling (a smaller image resolution) may result in better light sensitivity per sample (faster snapshots on less light). A bigger image sensor in combination with a given lens system will have also a bigger depth of field (see `DOF` below).

One cannot judge any of the above image sensor quality factors directly. The best way to evaluate a camera image sensor quality, is to take some photos with it at different resolutions and see if they please you. Digital image resolution matters for post image processing. The more pixels you get from the camera, more control you have later on on software (you can always scale down in software to remove noise details).

##Actual Zoom

An object with height $$$H\_1$$$ at distance $$$S\_1$$$ from the lens is projected into the image sensor at distance $$$S\_2$$$ from the lens. Image sensor has a fixed height $$$H\_2$$$. 'Zooming in' to the distant object means we want to map some sub-part of it with height $$$H\_{11} < H\_1$$$ into same $$$H\_2$$$ image sensor size. The actual zoom factor (magnification) is then $$$m = \frac{H\_1}{H\_{11}}$$$.

As both the image sensor and the distant object position does not change, we have to control (increase) $$$S\_2$$$ to a new value $$$S\_{21}$$$ to zoom in ($$$S\_1$$$ decreases when $$$S\_2$$$ in increased in focal length formula. $$$\frac{S\_{21}} {S\_2}$$$ is the **optical zoom** of the lens used to obtain the **actual zoom** $$$\frac{H\_1} { H\_{11}}$$$.

Difference between the optical zoom and the actual zoom depends on $$$S\_1$$$. If $$$S\_1$$$ is too big (the object is too far away) then $$$\frac{1} {S\_1}$$$ can be approximated to zero, so that $$$S\_2 = f$$$. If $$$S\_1$$$ is small, comparable to $$$S\_2$$$, then $$$S\_2 = 2f$$$. To zoom near objects same as distant ones we need a bigger $$$S\_2$$$. For the same $$$f$$$ range, near objects have a smaller actual zoom.

The smaller a distant object is, the less actual zoom we can get for it, when using a given focal range lens.

##Aperture

Aperture is an opening through which light travels [14]. For a camera the aperture can be measured physically by the diameter of the lens (the diameter of the lens entrance pupil is called aperture). Usually the aperture is measured as an `F-number` [15] which is the relative aperture:
$$
F = \frac{f}{D}
$$
Where `f` in the lens focal length and `D` the lens entrance pupil diameter. The F-number is written as `f/number`. The `f/` notation should not be confused with focal length `f`. In cameras, the F-number f/ if also written as `F`. The bigger the F-number, the smaller is the aperture (D is smaller).

In most cameras D can be controlled (either manually, or automatically). The controllable range of aperture in a camera lens is expressed as a F-number range. The minimal F-number is a property of the lens. The maximum one is mechanical (a camera property). My camera reports its supported F-number range as F2.8 to F8.0 - (actually (F2.8 - 8 (W) / F5.2 - 8 (T))).

An aperture range is physically an analog quantity, but digital cameras may only support changing it steps. The steps are by convention written as powers of 2 and are know as F-stops. Some F-stop examples are: f/1, f/1.4, f/2, f/2.8, f/4, f/5.6, f/8, f/11, f/16, f/22, f/32, .... The aperture can be also smaller than f/1. The f/2 is twice as small as f/1.4, and so on. These are also known as full F-stops. Some cameras may also step the aperture in one-half F-stops, or more detailed. My camera's F-number range from F2.8 to F8.0, contains 4 full F-stops and double that one-half F-stops.

F-number is related to the illumination (light) that can get into the camera. Indirectly, the F-number measures the lens speed because the more light gets via the lens into the image sensor, usually the faster it is to get the light data in the image sensor and produce an image. In this context, the smaller the supported F-number, the smaller is the shutter speed needed and the faster (better) is the camera.

The motivation to control the aperture and make it smaller (or bigger) is to create various effects. When using a big F-number (small aperture) less light rays will come per object and the image will be perceived as sharper - so the depth of field (DOF) of view can be controlled.

User-controlled aperture can be done before the lens from outside, or after the lens inside the camera automatically. The end result is usually same.

##Depth of Field

Depth of field (DOF) is the distance between the nearest ($$$D\_n$$$) and farthest ($$$D\_f$$$) objects in a scene that appear acceptably sharp in an image [22].
$$
DOF = D\_f - D\_n
$$
Circle of confusion (or blur spot) is an optical spot caused by a cone of light rays from a lens not coming to a perfect focus [23]. Circle of confusion diameter limit (CoC) for an image it is the largest blur spot that will still be perceived by the human eye as a point:
$$
CoC = D \frac{|S\_{12} - S\_1|}{S\_{12}} \frac{f}{S\_1 - f}
$$
Where $$$f$$$ is the lens focal length, $$$D$$$ the lens entrance pupil diameter (same as for F-number calculation), $$$S\_1$$$ is same as for the thin lens formula, and $$$S\_{12}$$$ is the point where $$$S\_1$$$ should be for it to look sharp.

The acceptable CoC (or acceptable sharpness) value for an image (what we perceive as blurred and not blurred) is used to determine depth of field. Depth of field can be measured in several ways, but a common way is via hyper-focal distance (H) [24]:
$$
H = \frac{f^2}{ F * CoC}
$$
Where $$$f$$$ is focal length, $$$F$$$ is the aperture, and $$$CoC$$$ is the acceptable $$$CoC$$$ value. A lens focused at $$$H$$$ will hold a depth of field from $$$\frac{H}{2}$$$ to infinity [24]. If $$$s$$$ is the distance where the camera is focused (subject distance), then for $$$s < H$$$:
$$
DOF = \frac{2 H s ^ 2} {H ^ 2 - s ^ 2}
$$

For a given sensor size $$$DOF$$$ is determined by three factors: the focal length of the lens $$$f$$$, the f-number of the lens opening (the aperture) (when f-number is bigger (aperture is smaller), $$$DOF$$$ is bigger), and the camera-to-subject distance.

When $$$s \approx f$$$ (called macro or close up photography) then $$$H$$$ is of no practical use and $$$DOF$$$ for macro photography is expressed in terms of image magnification m (actual zoom):
$$
DOF = 2 F \* CoC \* \frac{m + 1} {m ^ 2}
$$
The more complicated formulas based on thin lens (such as these above) are, the less accurate they are (thin lens are a mathematical abstraction for real physical lens).

My camera reports $$$DOF$$$ as the 'focusing area' (not to be confused with auto focus (AF) settings in the camera) with $$$D\_n-D\_f$$$ for normal photos: Wide 30 cm - infinity / Tele 200 cm - infinity, and $$$D\_n-D\_f$$$ for macro: Wide 1 cm - infinity / Tele 100cm - infinity. If I want to take a macro in low zoom, I can take it up to 1 cm near the object - at high zoom, I have to be 1 meter away. For normal photos, if I use the super-zoom, I have to be at least 2 meters far from the subject.

##Shutter Speed and Exposure

Aperture, as explained above, controls how much light can get it. Shutter speed controls for how long the light can get it via the aperture. Shutter speed is measured in `1 / second`. Exposure is how long the image sensor is exposed to light - measured in seconds. Both terms are used interchangeably. Exposure can vary from a long time, to a small fraction of a second.
$$
ShutterSpeed = \frac{1}{Exposure}
$$
Shutter speed is the speed to shot (the time the image sensor is allowed to gather the subject scene information), not the speed to process and store the image in the camera. A camera can have a fast shutter speed, but still be slow to process the (fast) captured image data and save them to storage. During the shutter (exposure) time, the camera must be held still.

The bigger the exposure the more light comes in. If the objects are moving in a field of view, the more motion blur the final image will contain. A smaller exposure is best most fast moving objects. For example, shutter speed of 1/2000s and 1/1000s is used to take sharp photographs of moderately fast subjects under normal lighting conditions [18]. The smaller the shutter speed supported, usually the better the camera is. Long shutter times have their own uses too (night photography, etc), so a good camera should support them too.

Exposure value (EV) is a quantitative way to measure both aperture and exposure [19] where ($$$F$$$ is the F-nummer):
$$
EV = log\_2(\frac{F ^ 2} {t})
$$
Here $$$t$$$ is the time in seconds. EV 0 corresponds to an exposure time of 1s and a relative aperture of f/1.0. If the EV is known, it can be used to select combinations of exposure time and f-number [19]. Usually cameras will allow you to control exposure around EV 0 (negative, or positive) and steps (stops) +/-1. Each +1 halves the exposure time or halving the aperture area, or a combination of such changes [19].

For my camera, the supported range is +/-3 EV, changeable in 1/3 EV steps.

Some cameras determine shutter speed automatically base on the user set aperture value (Aperture Priority), or the aperture based on the user set shutter value (Shutter Priority).

##Over and Under Exposure

Image areas can be classified into three classes based on amount of light brightness information they contain: shadows (low-light parts), middtones, and highlights (high-light parts). In middtones, there is usually to be found the neutral (middle) gray color (RGB=127,127,127 or RGB=128,128,128) (called also gray or white balance [34], based on color temperature [37]). If the middle gray has another RGB value, we have a color cast. The brightness range of values an image contains between its lightest and darkest parts is the **dynamic range**.

Over-exposure of an image causes loss of information in highlight detail - important bright parts of an image are "washed out" or effectively all white (blown out) [33]. There is more brightness information than needs to be.

Under-exposure of an image causes loss of information in shadow detail - important dark areas are "muddy" or indistinguishable from black. There is less brightness information than needs to be.

If you have no choice and are unsure, better under-expose a bit, rather than risk over-exposure.

Digital cameras have built-in sensors to do light metering and determine the right exposure automatically. A light meter is a device used to measure the amount of light, to determine the proper exposure for a photograph [25]. Based on light amount, the aperture, shutter speed, etc, can be selected (automatically or manually) in camera. Cameras measure usually the reflected light:
$$
\frac{F^2}{t} = \frac{L * S} {K}
$$
Where $$$F$$$ is the F-number, $$$t$$$ the exposure time in seconds (shutter speed), $$$L$$$ the average luminance, $$$S$$$ the ISO sensitivity, and $$$K$$$ is a camera specific calibration constant.

My camera supports several light metering options: Intelligent Multiple / Center Weighted / Spot. These are basically different methods to measure light. Spot measures light in focus (center) spot, center weighted prefers the center but also considers the edges (the farer, the less considered), and intelligent multiple has to be some more clever way to consider lights from many interesting points at once.

##Image Sensor Light Sensitivity

Luminous flux or luminous power is the measure of the perceived power of light (per spherical unit) measured in lumen (lm) [31] (translated: how much light seems to be produced by a source). Illuminance is the total luminous flux incident on a surface, per unit area [30] measured in lux (lx) = lm/squaremeter [17] (translated: how much light is receviced and reflected by a destination). Illuminance can be seen as the intensity of light reflected or emitted by a surface. Luminance (L) is measure of the luminous intensity per unit area of light traveling in a given direction. Luminance is an indicator of how bright the surface will appear.

Luminance is invariant in lens optics: the luminance at the output is the same as the input one [30]. The luminous power is concentrated into a image sensor smaller area, meaning that the illuminance is higher at the image that at source. The projected image can never be "brighter" than the source [30].

Some common illuminance values of lux from [17] for surfaces being illuminated by: Direct sunlight: 32,000-130,000 lux, Sunrise or sunset on a clear day: 400 lux, Family living room lights: 50 lux, Full moon on a clear night: 0.27-1.0 lux. My camera supports at low light mode (shutter speed 1/25s) a minimum illumination of 9 lux.

In digital camera systems, an arbitrary relationship between exposure and image sensor data values can be achieved by controlling the signal gain of the sensor [20]. The sensor sensitivity to light is measured via ISO setting (called also ISO speed). ISO setting is an exposure index (EI) rating such that the sRGB image files produced by the camera will have a lightness similar to what would be obtained with film of the same EI rating at the same exposure [20].

The lowest ISO setting (the least sensitive) is 100. From there, each ISO setting, or stop, doubles in sensitivity and in number: 200, 400, 800, and so on [32]. The bigger the ISO the more sensitive the sensor is (the bigger the gain) for both signal and noise. The actual noise level on each ISO setting depends also on the camera sensor quality.

For my camera, the ISO ranges from 100 to 3200 with a high sensitivity mode with ISO range 1600 - 6400.

##Lens Distortion

Optical lens have various kinds of light distortion and aberration [28] (mostly because real lens have infinite layers of different nodal-points). The most visible ones are: barrel distortion where straight lines in a scene do not remain straight in an image [27] - especially on the sides; and chromatic aberration where the colors get slightly shifted as they are reflected at slightly different angles - mostly visible on object edges.

In most digital cameras with built-in lens, the angle of coverage (the part of lens aperture applied to the image sensor) is usually smaller than the physically visible lens diameter to compensate for the distortion. Also the image sensor is usually a square, while lens form a circle, so only a part of the light coming through the circle gets into the square image sensor.

Natural light is diffused reflected light. A lens system may diffuse even more the light that goes through it. The more parts the lens are made of, the more the light gets diffused. This shows up in images as unsharpened object boundaries – where the light in object edges in mixture of the object colors and the background ones. The final image can be sharpened with post-processing either built-in the camera, or in software.

##Image Post-Processing

All digital cameras do some image signal post-processing in the camera (e.g., sampling, sharpening, noise reduction). The relationship between the sensor data values and the lightness of the finished image is arbitrary, depending on the parameters chosen for the interpretation of the sensor data into an image color space, such as sRGB [20].

In some cameras it is possible to get the RAW image data produced by the digital image sensor and then remap them on your own as you like using your a camera profile. Usually a raw conversion profile (same or similar to the one built-in in the camera) is provided by the manufacturer of the camera, as the manufacturer knows best what the raw data are, and then various image parameters can be further adjusted via software.

Raw data processing can help, for example, get various exposures on your own from the same photo, but is also a time consuming process. For most use cases, relying on the built-in automatic camera processing that engineers have put in is faster and good enough or even better (a camera can have several built-in raw conversion profiles and select the best of them for the given image as needed) that what you can come up with on your own using the raw data. Do not discard camera JPEG images, rather use raw files to help enhance or fix parts of them.

Taking several shots of the same scene at different exposures (called 'bracketing') helps gather a higher dynamic range of light information as different images that can then combined as needed into a single one using software. My digital camera offers a automatic bracketing feature that records three images at different exposures for every shot - a tripod helps avoiding centering and registering the three different images later.

##Automatic Mode

No matter what level of manual control a digital camera offers, most of the time you will use it in its automatic mode. It takes time to set up manual camera parameters, such as, aperture and exposure right for every shot by trial and error (even in a controlled studio light environment), and the subject you want to photograph may not be available (in its original form) for that long.

While it is good to know how to set up a camera to take a manual shot, always fully test whether auto-mode can handle most of what you plan to use a camera for. Observing the aperture, exposure, and ISO speed parameters used by auto-mode for each successful image (stored as part of EXIF data for camera JPEG files), is also a great way to learn more about them, if you ever need to set them manually.

##Printing

For printed images to look good around 300 dpi (dots per inch) are needed or approximately 118 dots per centimeter. For low quality printing you can go also with 150dpi ( ~ 59 dots per centimeter). There are two image shooting factors that affect printing quality, both the higher the better:

* Resolution. To find the optional print size divide resolution by the above constants. E.g.: `6MP => 3280 x 2048 pixels => 3280 / 118 x 2048 / 118 ~= 28 x 17 cm `. This is the optimal size. As a rule of thumb you can go 2 to 3 times digital zoom this size and still look acceptable.
* Encoding quality (in case of JPEG format). Most cameras have a large quality setting that should be normally preferred. The bigger the quality is, the better digital zoom looks like (and more color information the photo contains). JPEG files with better quality are bigger in size for same resolution.

If you prepare a photo for printing, better upscale (or downscale) the photo using software to the correct printing size with the correct DPI, rather than allow the printer handle it.

##References

1. https://en.wikipedia.org/wiki/Focal_length

2. http://scienceworld.wolfram.com/physics/ThickLensFormula.html

3. http://scienceworld.wolfram.com/physics/ThinLensFormula.html

4. http://scienceworld.wolfram.com/physics/GaussianLensFormula.html

5. http://photo.stackexchange.com/questions/13717/how-do-i-convert-lens-mm-to-optical-zoom-times

6. https://en.wikipedia.org/wiki/Angle_of_view

7. http://en.wikipedia.org/wiki/Human_eye

8. http://www.cambridgeincolour.com/tutorials/cameras-vs-human-eye.htm

9. https://en.wikipedia.org/wiki/135_film

10. https://en.wikipedia.org/wiki/Crop_factor

11. http://en.wikipedia.org/wiki/Image_sensor_format

12. https://en.wikipedia.org/wiki/Field_of_view

13. http://www.paragon-press.com/lens/lenchart.htm

14. https://en.wikipedia.org/wiki/Aperture

15. https://en.wikipedia.org/wiki/F-number

16. https://en.wikipedia.org/wiki/Collimated

17. http://en.wikipedia.org/wiki/Lux

18. http://en.wikipedia.org/wiki/Shutter_speed

19. http://en.wikipedia.org/wiki/Exposure_value

20. http://en.wikipedia.org/wiki/Film_speed

21. http://www.cambridgeincolour.com/tutorials/camera-exposure.htm

22. http://en.wikipedia.org/wiki/Depth_of_field

23. http://en.wikipedia.org/wiki/Circle_of_confusion

24. http://en.wikipedia.org/wiki/Hyperfocal_distance

25. http://en.wikipedia.org/wiki/Light_meter

26. http://www.cambridgeincolour.com/tutorials/camera-metering.htm

27. http://en.wikipedia.org/wiki/Distortion_%28optics%29

28. http://en.wikipedia.org/wiki/Aberration_in_optical_systems

29. http://en.wikipedia.org/wiki/Luminance

30. http://en.wikipedia.org/wiki/Illuminance

31. http://en.wikipedia.org/wiki/Luminous_flux

32. http://www.howstuffworks.com/what-is-iso-speed.htm

33. http://en.wikipedia.org/wiki/Exposure_%28photography%29

34. http://en.wikipedia.org/wiki/Color_balance

35. http://en.wikipedia.org/wiki/Diffuser_%28optics%29

36. http://en.wikipedia.org/wiki/Exposure_range

37. http://en.wikipedia.org/wiki/Color_temperature


<ins class='nfooter'><a id='fprev' href='#blog/2013/2013-03-04-Google-Hangout-Share-both-Screen-and-Camera.md'>Google Hangout Share both Screen and Camera</a> <a id='fnext' href='#blog/2013/2013-03-01-DNS-Caching-and-VPN.md'>DNS Caching and VPN</a></ins>
